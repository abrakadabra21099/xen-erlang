-module(xen_quorum).

-export([new/1, threshold/1, has_quorum/2, weight_of/2]).

-type voter() :: term().
-type membership() :: #{weights := #{voter() => pos_integer()}, total_weight := pos_integer()}.
-type membership_error() :: empty_membership | invalid_membership | {invalid_weight, voter()} | {duplicate_voter, voter()} | invalid_entry.

-spec new([{voter(), integer()}]) -> {ok, membership()} | {error, membership_error()}.
new([]) ->
    {error, empty_membership};
new(Voters) when is_list(Voters) ->
    build_membership(Voters, #{}, 0);
new(_Malformed) ->
    {error, invalid_membership}.

-spec threshold(membership()) -> pos_integer().
threshold(#{total_weight := Total}) ->
    Total div 2 + 1.

-spec has_quorum(membership(), [voter()]) -> boolean().
has_quorum(#{weights := Weights, total_weight := Total}, Acknowledgers) ->
    Threshold = Total div 2 + 1,
    AcknowledgedWeight = lists:foldl(
        fun(Voter, Acc) -> Acc + maps:get(Voter, Weights, 0) end,
        0,
        lists:usort(Acknowledgers)
    ),
    AcknowledgedWeight >= Threshold.

-spec weight_of(membership(), voter()) -> {ok, pos_integer()} | error.
weight_of(#{weights := Weights}, Voter) ->
    maps:find(Voter, Weights).

build_membership([], Weights, Total) ->
    {ok, #{weights => Weights, total_weight => Total}};
build_membership([{Voter, Weight} | Rest], Weights, Total)
        when is_integer(Weight), Weight > 0 ->
    case maps:is_key(Voter, Weights) of
        true ->
            {error, {duplicate_voter, Voter}};
        false ->
            build_membership(Rest, Weights#{Voter => Weight}, Total + Weight)
    end;
build_membership([{Voter, _Weight} | _Rest], _Weights, _Total) ->
    {error, {invalid_weight, Voter}};
build_membership([_Malformed | _Rest], _Weights, _Total) ->
    {error, invalid_entry}.
