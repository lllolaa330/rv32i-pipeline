"""Verify archived screenshot hashes; optionally compare with the local PPTX."""
import argparse
import hashlib
import json
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[1]

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--presentation', type=Path, help='Original PPTX, kept outside the repository')
    args=parser.parse_args()
    manifest=json.loads((ROOT/'docs/source-images/manifest.json').read_text())
    for item in manifest:
        data=(ROOT/item['file']).read_bytes()
        if hashlib.sha256(data).hexdigest()!=item['sha256']:
            raise SystemExit(f"Screenshot hash mismatch: {item['file']}")
    if args.presentation:
        expected='c9b839ec8ffc743fb893c1224b85255904bef081b53cc17809e16bbc1b668499'
        if hashlib.sha256(args.presentation.read_bytes()).hexdigest()!=expected:
            raise SystemExit('Original presentation hash mismatch')
        with zipfile.ZipFile(args.presentation) as deck:
            for item in manifest:
                media=Path(item['file']).name.split('-',1)[1]
                if deck.read('ppt/media/'+media)!=(ROOT/item['file']).read_bytes():
                    raise SystemExit(f"Presentation media mismatch: {media}")
            if deck.read('ppt/media/image14.png')!=(ROOT/'docs/assets/pipeline.png').read_bytes():
                raise SystemExit('Architecture image mismatch')
    print(f'PASS: {len(manifest)} archived code screenshots match their SHA-256 manifest.')
    if args.presentation:
        print('PASS: presentation hash, code screenshots and architecture image match the original PPTX.')
    print('This checks source-image integrity, not semantic equivalence of transcribed RTL.')

if __name__=='__main__':
    main()
