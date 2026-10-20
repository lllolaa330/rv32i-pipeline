"""Recalculate the historical table. Does not run the CPU or original benchmarks."""
import json
from pathlib import Path

def main():
    data=json.loads((Path(__file__).resolve().parents[1]/'docs/benchmark-data.json').read_text())
    rows=data['rows']; n=len(rows)
    pipeline=sum(r['pipeline_cycles'] for r in rows)
    reference=sum(r['reference_cycles'] for r in rows)
    extra=sum(r['reported_extra_cycles'] for r in rows)
    print('Historical data only; test7 excluded by original presentation.')
    print('| Test | Pipeline | Reference | Difference | Reported extra |')
    print('| --- | ---: | ---: | ---: | ---: |')
    for r in rows:
        print(f"| {r['test']} | {r['pipeline_cycles']} | {r['reference_cycles']} | {r['pipeline_cycles']-r['reference_cycles']} | {r['reported_extra_cycles']} |")
    print(f'| Mean | {pipeline/n:.2f} | {reference/n:.2f} | {(pipeline-reference)/n:.2f} | {extra/n:.2f} |')
    print(f'Aggregate cycle ratio: {pipeline/reference:.8f}; additional cycles: {(pipeline/reference-1)*100:.4f}%')
    offsets={r['pipeline_cycles']-r['reference_cycles']-r['reported_extra_cycles'] for r in rows}
    print(f'Difference minus reported extra, distinct values: {sorted(offsets)}')
    print('The source mean row is preserved in JSON but not used in the calculation.')

if __name__=='__main__':
    main()
