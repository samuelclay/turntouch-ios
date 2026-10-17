#!/usr/bin/env python3
"""Capture genuine localized Store UI through run_ios.py on prepared simulators."""
import argparse
import json
import hashlib
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
DEVICES = {
    'iphone': ('011EB534-697E-4855-BACA-4D4C6E4E92EF', '410,90', '390,238'),
    'iphone-medium': ('2CA00BFF-4F74-483A-8214-63974AD8FF90', '371,92', '356,238'),
    'ipad': ('883650D4-245E-4265-84A5-97606867CB5B', '1001,60', '986,207'),
}
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--devices', nargs='+', choices=DEVICES, default=list(DEVICES))
parser.add_argument('--languages', nargs='+', default=['all'])
parser.add_argument('--resume', action='store_true')
args = parser.parse_args()
locales = json.loads((ROOT / 'localization/store-locales.json').read_text())
languages = list(locales) if args.languages == ['all'] else args.languages
if not set(languages) <= set(locales):
    parser.error('Unsupported language')
for lang in languages:
    for kind in args.devices:
        udid, gear, change = DEVICES[kind]
        out = ROOT / 'store' / locales[lang] / 'images' / kind
        out.mkdir(parents=True, exist_ok=True)
        paths = [out / f'{name}.png' for name in ['01-remote', '02-settings', '03-apps']]
        if args.resume and all(p.exists() for p in paths):
            continue
        copy = json.loads((ROOT / 'localization/translations' / (lang + '.json')).read_text()) if lang != 'en' else {}
        tr = lambda key: copy.get(key, key)
        actions = ['home', 'sleep:1', 'terminate', 'launch:' + lang, 'sleep:3',
                   'screenshot:' + str(paths[0]), 'tap-id:settings-button', 'sleep:1', 'assert-label:' + tr('Language'),
                   'screenshot:' + str(paths[1]), 'tap-label:' + tr('Done'), 'sleep:1', 'tap-label:' + tr('Change'),
                   'sleep:1', 'screenshot:' + str(paths[2])]
        subprocess.run([sys.executable, str(ROOT / 'run_ios.py'), '--udid', udid, *actions], check=True)
        if not all(p.exists() and p.stat().st_size > 10000 for p in paths):
            raise RuntimeError(f'Incomplete capture: {lang} {kind}')
        if len({hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}) != 3:
            raise RuntimeError(f'Duplicate scene captures: {lang} {kind}')
        print('CAPTURED', lang, kind, flush=True)
