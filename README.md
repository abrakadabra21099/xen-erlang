# Xen Erlang Backend

An Erlang/OTP implementation of a distributed Xen control plane. Every control-plane node will accept client requests and participate in leaderless, weighted consensus. Worker nodes execute workloads and do not contribute to quorum weight.

## Current status

The repository starts with an OTP application/supervisor and a tested static weighted-majority module. Membership weights are positive integers configured explicitly; a voter contributes only its configured weight, and duplicate acknowledgements count once. The next implementation stages are joint membership, leaderless Paxos, durable local state, peer transport, the client API, and Xen `libxl` integration.

The design carries forward these decisions from the initial prototype:

- No elected or fixed leader; every control-plane node may accept requests.
- Separate control-plane quorum weights from workload-placement policy.
- Use weighted majorities; membership transitions require quorums under both old and new configurations.
- Keep worker nodes outside the voter set.
- Start with cleartext host-to-host transport for the MVP, with a later TLS or SSH transport layer.

## Requirements and commands

Requires Erlang/OTP 29 or newer and rebar3.

```sh
rebar3 compile
rebar3 eunit
```

## Layout

- `src/` — OTP application, supervision tree, and cluster modules.
- `test/` — EUnit tests.
- `docs/` — architecture and consensus decisions.
- `schema/` — Xen domain configuration schema for PV, PVH, and HVM guests.

The domain schema from the Rust prototype is retained at
`schema/xl-domain.schema.json`; runtime validation and conversion to `libxl`
structures are still to be implemented.
