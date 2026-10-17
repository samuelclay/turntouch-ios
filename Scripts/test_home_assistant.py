#!/usr/bin/env python3
"""Compile the real ObjC client and test it against a loopback HA protocol fixture."""
import json
import pathlib
import subprocess
import tempfile
import shutil
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs

ROOT = pathlib.Path(__file__).resolve().parents[1]
records = []
class Fixture(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass
    def reply(self, status, payload):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(payload).encode())
    def do_GET(self):
        if self.headers.get('Authorization') not in ('Bearer fixture-token', 'Bearer oauth-token', 'Bearer refreshed-token'):
            return self.reply(401, {})
        if self.path == '/api/': return self.reply(200, {'message': 'API running.'})
        if self.path == '/api/states':
            return self.reply(200, [{'entity_id': eid, 'state': 'off', 'attributes': {'friendly_name': name}}
                for eid, name in [('light.desk', 'Desk'), ('scene.evening', 'Evening'), ('automation.evening', 'Evening automation')]])
        if self.path == '/api/services':
            return self.reply(200, [{'domain': domain, 'services': {service: {'target': {}, 'fields': {}} for service in services}}
                for domain, services in [('light', ['toggle', 'turn_on', 'turn_off']), ('scene', ['turn_on']), ('automation', ['trigger'])]])
        return self.reply(404, {})
    def do_POST(self):
        raw = self.rfile.read(int(self.headers.get('Content-Length', '0')))
        if self.path == '/auth/token':
            fields = parse_qs(raw.decode())
            assert fields['client_id'] == ['https://turntouch.com']
            records.append((self.path, fields))
            if fields['grant_type'] == ['authorization_code']:
                assert fields['code'] == ['fixture-code']
                return self.reply(200, {'access_token': 'oauth-token', 'refresh_token': 'fixture-refresh', 'expires_in': 1})
            assert fields['refresh_token'] == ['fixture-refresh']
            return self.reply(200, {'access_token': 'refreshed-token', 'expires_in': 1800})
        if self.headers.get('Authorization') not in ('Bearer fixture-token', 'Bearer refreshed-token'):
            return self.reply(401, {})
        records.append((self.path, json.loads(raw)))
        if self.path == '/api/services/light/redirect':
            self.send_response(302)
            self.send_header('Location', '/should-never-be-called')
            self.end_headers()
            return
        if self.path == '/api/services/light/denied': return self.reply(403, {})
        return self.reply(200, [])

with tempfile.TemporaryDirectory(prefix='turntouch-ios-ha-tests-') as tmp:
    binary = pathlib.Path(tmp) / 'client-tests'
    subprocess.run(['xcrun', 'clang', '-fobjc-arc', '-fmodules', '-framework', 'Foundation', '-framework', 'Security',
        '-I', str(ROOT / 'Turn Touch iOS/Modes/HomeAssistant'),
        str(ROOT / 'Turn Touch iOS/Modes/HomeAssistant/TTHomeAssistantClient.m'),
        str(ROOT / 'HomeAssistantUITests/HomeAssistantClientChecks.m'), '-o', str(binary)], check=True)
    server = ThreadingHTTPServer(('127.0.0.1', 0), Fixture)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    try:
        subprocess.run([str(binary), f'http://127.0.0.1:{server.server_port}'], check=True, timeout=60)
        assert not any(path == '/should-never-be-called' for path, body in records)
        assert any(path == '/api/services/automation/trigger' and body == {'entity_id': 'automation.evening', 'skip_condition': False} for path, body in records)
    finally:
        server.shutdown()
