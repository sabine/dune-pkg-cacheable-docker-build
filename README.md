# Dune pkg cacheable Docker build benchmark

This repo is a minimal OCaml project that demonstrates a cacheable Docker layer for Dune Package Management.
It is intentionally tiny, but still builds the OCaml compiler and packages from the `dune.lock` file so you
can see the Docker layer cache savings.

This is how I personally handle it. It is not a recommendation from the Dune team. I would love feedback
or to hear how others handle this.

## What this shows

- `Dockerfile.unoptimized`: copies the full repo first, so any source change invalidates the layer that builds
  the OCaml compiler and all dependencies.
- `Dockerfile.optimized`: copies only `dune-project` + `dune.lock` and builds a dummy target first, so the
  expensive compiler + dependency layer is cached. The real source code is copied afterward.

## Run the benchmark

Cold builds:

```bash
time docker build -f Dockerfile.unoptimized .
time docker build -f Dockerfile.optimized .
```

Warm builds (after editing `src/site.ml`):

```bash
printf '%s\n' 'let () = print_endline "Hello again"' > src/site.ml
time docker build -f Dockerfile.unoptimized .
time docker build -f Dockerfile.optimized .
```

## Benchmark results

Architecture:

- OS: Linux pop-os 6.17.9-76061709-generic
- CPU: AMD Ryzen 7 7840HS (16 threads)
- Arch: x86_64

Timings (local Docker, BuildKit enabled):

- Unoptimized runs (s): 0.66, 0.46, 0.48, 91.99, 94.68, 87.12, 88.49, 88.38, 90.22, 87.61
- Optimized runs (s): 0.46, 0.49, 0.47, 5.53, 1.52, 1.77, 1.46, 1.46, 1.79, 1.44
- Average (10 runs): unoptimized 63.009s, optimized 1.639s
- Average (runs 4-10 only): unoptimized 89.784s, optimized 2.139s

Notes on the averages:

- The first three runs were full-cache hits (sub-second) on this machine.
- The run 4-10 average is a better picture of the usual warm rebuild time after a source change.

## Notes

- The cache boundary is the `COPY dune.lock/` + dummy build layer.
- This is Docker layer caching, not the Dune cache.

