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

- Cold build, unoptimized: 1m32.341s
- Cold build, optimized: 1m32.378s
- Warm build (after changing src/site.ml), unoptimized: 1m30.495s
- Warm build (after changing src/site.ml), optimized: 0m1.586s

## Notes

- The cache boundary is the `COPY dune.lock/` + dummy build layer.
- This is Docker layer caching, not the Dune cache.

If you are not using Docker in CI, you can use https://github.com/ocaml-dune/setup-dune/ for installing Dune.

## GitHub Actions example

See `.github/workflows/docker-benchmark.yml` for a simple workflow.
