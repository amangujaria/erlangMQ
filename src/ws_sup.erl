-module(ws_sup).

-behaviour(supervisor).

-export([start_link/0, init/1, web_proc/1, start_child/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    SupFlags = {simple_one_for_one, 1, 1},
    ChildSpecs = [{?MODULE, {?MODULE, web_proc, []}, permanent, brutal_kill, worker, dynamic}],
    {ok, {SupFlags, ChildSpecs}}.

start_child(Pid) ->
    supervisor:start_child(?MODULE, [Pid]).

web_proc(Pid) ->
    {ok, Pid}.
