-module(routes).

%%-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    Dispatch = cowboy_router:compile([
        {'_',
            [
                {"/", handler, []},
                {"/websocket", ws_h, []},
                {"/list/quantity", handler, [{list, quantity}]},
                {"/list/queues", handler, [{list, queues}]},
                {"/create/queue/:queue_id", handler, [create]},
                {"/update/queue/:queue_id", handler, [update]},
                {"/delete/queue/:queue_id", handler, [delete]}
            ]
        }
    ]),
    StartRes = cowboy:start_clear(http, [{port, 8080}], #{env => #{dispatch => Dispatch}}),
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    SupFlags = {one_for_one, 1, 1},
    {ok, {SupFlags, []}}.
