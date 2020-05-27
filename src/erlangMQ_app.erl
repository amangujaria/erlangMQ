%%%-------------------------------------------------------------------
%% @doc erlangMQ public API
%% @end
%%%-------------------------------------------------------------------

-module(erlangMQ_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    erlangMQ_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
