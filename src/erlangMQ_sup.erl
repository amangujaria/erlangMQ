%%%-------------------------------------------------------------------
%% @doc erlangMQ top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(erlangMQ_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{strategy => one_for_one,
                 intensity => 1,
                 period => 1},
    ChildSpecs = [
    {routes, {routes, start_link, []}, permanent, brutal_kill, worker, [routes]},
    {ws_sup, {ws_sup, start_link, []}, permanent, brutal_kill, supervisor, [ws_sup]},
    {broker, {broker, start_link, []}, permanent, brutal_kill, supervisor, [broker]}],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
