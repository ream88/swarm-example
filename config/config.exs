import Config

config :libcluster,
  topologies: [
    local_epmd_example: [
      strategy: Elixir.Cluster.Strategy.LocalEpmd
    ]
  ]
