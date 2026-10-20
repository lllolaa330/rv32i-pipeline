.PHONY: check test sources benchmark
check: sources benchmark test
sources:
	python3 scripts/verify_sources.py
benchmark:
	python3 scripts/benchmark_summary.py
test:
	python3 -m unittest discover -s tests -v
