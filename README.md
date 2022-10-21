# A Elixir cluster example using swarm

This is an example of an Elixir app which allows rolling deploys using [`swarm`](https://hex.pm/packages/swarm).

```sh
iex --name a -S mix
iex --name b -S mix
```

```sh
App.start_worker(:alice)
App.start_worker(:bob) # On node b
```
