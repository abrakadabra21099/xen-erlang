# Consensus model

## Goals

The control plane is master-master: every control-plane node can serve client requests and propose commands. There is no elected API leader. Workers execute assigned workloads but never participate in consensus.

Voter weights express quorum influence only. They are assigned when a control-plane node joins and change only through an explicit committed membership operation. Placement weights and scheduling are separate concerns and are outside the current MVP.

For stable membership, a quorum has strictly more than half of the configured total voter weight. During membership changes, a decision must satisfy both the old and new weighted majorities. Duplicate acknowledgements count once; unknown voters contribute no weight.

## Transport and security

The MVP peer transport may use cleartext on a trusted cluster network. The protocol must be designed so TLS or SSH can be layered over the host connection later. Cleartext mode does not authenticate peers and must not be treated as safe across untrusted networks.

## Implementation sequence

1. OTP application and weighted quorum primitives.
2. Joint membership state transitions.
3. Leaderless Paxos rounds and durable acceptor state.
4. Peer RPC transport and multi-slot log coordination.
5. Client API on every control-plane node.
6. Replicated command application, worker agents, and Xen `libxl` integration.
