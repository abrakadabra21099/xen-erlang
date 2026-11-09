-module(xen_erlang_app_tests).

-include_lib("eunit/include/eunit.hrl").

application_start_starts_supervisor_test() ->
    {ok, Pid} = xen_erlang_app:start(normal, []),
    unlink(Pid),
    ?assert(is_process_alive(Pid)),
    exit(Pid, shutdown),
    ?assertEqual(ok, xen_erlang_app:stop([])).

supervisor_uses_one_for_one_strategy_test() ->
    ?assertEqual(
        {ok, {{one_for_one, 5, 10}, []}},
        xen_erlang_sup:init([])
    ).
