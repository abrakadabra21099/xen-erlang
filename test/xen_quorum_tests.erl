-module(xen_quorum_tests).

-include_lib("eunit/include/eunit.hrl").

strict_majority_uses_all_configured_weight_test() ->
    {ok, Membership} = xen_quorum:new([{a, 1}, {b, 1}, {c, 1}]),
    ?assertEqual(2, xen_quorum:threshold(Membership)),
    ?assertNot(xen_quorum:has_quorum(Membership, [a])),
    ?assert(xen_quorum:has_quorum(Membership, [a, b])).

voter_weight_changes_majority_calculation_test() ->
    {ok, Membership} = xen_quorum:new([{a, 3}, {b, 1}, {c, 1}]),
    ?assertEqual(3, xen_quorum:threshold(Membership)),
    ?assert(xen_quorum:has_quorum(Membership, [a])),
    ?assertNot(xen_quorum:has_quorum(Membership, [b, c])).

duplicate_acknowledgements_count_once_test() ->
    {ok, Membership} = xen_quorum:new([{a, 1}, {b, 1}, {c, 1}]),
    ?assertNot(xen_quorum:has_quorum(Membership, [a, a, a])).

unknown_voters_do_not_contribute_weight_test() ->
    {ok, Membership} = xen_quorum:new([{a, 1}, {b, 1}, {c, 1}]),
    ?assertNot(xen_quorum:has_quorum(Membership, [a, unknown])).

membership_rejects_empty_and_nonpositive_weights_test() ->
    ?assertEqual({error, empty_membership}, xen_quorum:new([])),
    ?assertEqual({error, {invalid_weight, a}}, xen_quorum:new([{a, 0}])),
    ?assertEqual({error, {invalid_weight, a}}, xen_quorum:new([{a, -1}])).

membership_rejects_malformed_entries_test() ->
    ?assertEqual({error, invalid_entry}, xen_quorum:new([malformed])).

membership_rejects_non_list_input_test() ->
    ?assertEqual({error, invalid_membership}, xen_quorum:new(not_a_list)).

membership_rejects_duplicate_voters_test() ->
    ?assertEqual(
        {error, {duplicate_voter, a}},
        xen_quorum:new([{a, 1}, {a, 2}])
    ).

voter_weight_lookup_test() ->
    {ok, Membership} = xen_quorum:new([{a, 4}]),
    ?assertEqual({ok, 4}, xen_quorum:weight_of(Membership, a)),
    ?assertEqual(error, xen_quorum:weight_of(Membership, unknown)).
