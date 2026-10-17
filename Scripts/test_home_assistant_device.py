#!/usr/bin/env python3
"""Run the native Home Assistant UI flow against a non-actuating fixture on a physical device."""
import argparse
import pathlib
import plistlib
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--device', required=True)
parser.add_argument('--server', required=True, help='Reachable URL of home_assistant_fixture.py')
parser.add_argument('--derived-data', default='/tmp/turntouch-ha-ios')
parser.add_argument('--results', default=None)
args = parser.parse_args()
root = pathlib.Path(__file__).resolve().parents[1]
base = ['xcodebuild', '-workspace', str(root/'Turn Touch iOS.xcworkspace'), '-scheme', 'Home Assistant Tests',
        '-configuration', 'Debug', '-destination', f'platform=iOS,id={args.device}', '-derivedDataPath', args.derived_data,
        'IPHONEOS_DEPLOYMENT_TARGET=17.0', '-allowProvisioningUpdates']
subprocess.run(base + ['build-for-testing'], check=True)
products = pathlib.Path(args.derived_data)/'Build/Products'
run = max(products.glob('Home Assistant Tests*.xctestrun'), key=lambda p: p.stat().st_mtime)
data = plistlib.loads(run.read_bytes())
targets = ([target for config in data['TestConfigurations'] for target in config['TestTargets']]
           if 'TestConfigurations' in data else [value for key, value in data.items() if not key.startswith('__')])
for target in targets:
    target.setdefault('EnvironmentVariables', {})['HA_TEST_URL'] = args.server.rstrip('/')
# Keep the file next to the build products: __TESTROOT__ paths are relative to it.
prepared = products/'HomeAssistant-device.xctestrun'
prepared.write_bytes(plistlib.dumps(data))
result = args.results or tempfile.mkdtemp(prefix='turntouch-ha-results-')+'/Device.xcresult'
subprocess.run(['xcodebuild', 'test-without-building', '-xctestrun', str(prepared), '-destination', f'platform=iOS,id={args.device}', '-resultBundlePath', result], check=True)
print(result)
