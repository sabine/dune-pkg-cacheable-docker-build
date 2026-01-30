# Dune pkg cacheable Docker build benchmark

This repo is a minimal OCaml project that demonstrates a cacheable Docker layer for Dune Package Management.
It is intentionally tiny, but still builds the OCaml compiler and packages so you can see the Docker layer
cache savings.

Blog post: https://makerprism.com/en/blog/a-practical-docker-cache-pattern-for-dune-package-management/

This is how I personally handle it. It is not a recommendation from the Dune team. I would love feedback
or to hear how others handle this.

## What this shows

- `Dockerfile.unoptimized`: copies the full repo first, so any source change invalidates the layer that builds
  the OCaml compiler and all dependencies.
- `Dockerfile.optimized`: copies only `dune-project`, runs `dune pkg lock`, and builds a dummy target first,
  so the expensive compiler + dependency layer is cached. The real source code is copied afterward.

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

- Average warm rebuild (3 runs, after cache warm-up): unoptimized 118.593s, optimized 1.907s

## Notes

- The cache boundary is the `dune pkg lock` + dummy build layer.
- `dune.lock` is generated during the Docker build and is not checked in.
- This is Docker layer caching, not the Dune cache.
