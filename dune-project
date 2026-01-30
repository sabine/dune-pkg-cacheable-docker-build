(lang dune 3.9)

(name dune_pkg_cacheable_docker_build)

(source
 (github sabine/dune-pkg-cacheable-docker-build))

(authors "Sabine Schmaltz")
(maintainers "Sabine Schmaltz")

(package
 (name dune_pkg_cacheable_docker_build)
 (allow_empty)
 (synopsis "Benchmark: cacheable Dune pkg Docker builds")
 (description "Minimal OCaml project for benchmarking Docker layer caching with Dune package management")
 (depends
  (ocaml (>= 5.0))))
