#!/usr/bin/env python3
"""Refresh store asset checksums and the local HTML gallery (uses macOS sips)."""
from pathlib import Path
import subprocess
import json, hashlib, html

ROOT = Path(__file__).resolve().parent.parent
platform = 'ios'
version = '3.1'
root = ROOT
locales = json.loads((root / "localization/store-locales.json").read_text())
rows=[];sections=[]
for lang,locale in locales.items():
 paths=sorted((root/'store'/locale/'images').rglob('*.png'))
 if platform=='ios': paths+=sorted((root/'store/artwork/exports'/lang).glob('*'))
 cards=[]
 for p in paths:
  info = subprocess.check_output(["sips", "-g", "pixelWidth", "-g", "pixelHeight", str(p)], text=True)
  dimensions = {line.split(":")[0].strip(): line.split(":")[1].strip() for line in info.splitlines()[1:]}
  w, h = int(dimensions["pixelWidth"]), int(dimensions["pixelHeight"])
  rel=p.relative_to(root).as_posix()
  rows.append(dict(language=lang,locale=locale,file=rel,width=w,height=h,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
  src=p.relative_to(root/'store').as_posix()
  cards.append(f'<figure><a href="{src}"><img loading="lazy" src="{src}" alt="{html.escape(lang+" "+p.stem)}"></a><figcaption>{html.escape(p.parent.name+" / "+p.name)}<br>{w} × {h}</figcaption></figure>')
 sections.append(f'<section id="{lang}"><h2>{lang} · {locale}</h2><div class="grid">'+''.join(cards)+'</div></section>')
(root/'store/manifest.json').write_text(json.dumps(dict(version=version,assets=rows),ensure_ascii=False,indent=2)+'\n')
nav=' · '.join(f'<a href="#{l}">{l}</a>'for l in locales)
doc='<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Turn Touch '+platform+' localized assets</title><style>body{font:16px system-ui;margin:32px;background:#f6f3ee;color:#19334a}nav{position:sticky;top:0;background:#f6f3ee;padding:16px}a{color:#245677}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:20px}figure{margin:0;padding:12px;background:white;border-radius:12px}img{width:100%;height:360px;object-fit:contain}figcaption{font-size:12px;overflow-wrap:anywhere}h2{margin-top:48px}</style><h1>Turn Touch '+platform+' '+version+'</h1><p>21 languages. Genuine app screenshots and localized promotional artwork. Click an image to view the original.</p><nav>'+nav+'</nav>'+''.join(sections)+'</html>'
(root/'store/localized-gallery.html').write_text(doc)
print(platform,len(rows),'assets indexed')
