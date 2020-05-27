-module(broker).

-behaviour(gen_server).

-export([start_link/0, init/1, publish/2, subscribe/2]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    ets:new(messages, [bag, named_table, public]),
    ets:new(subscribers, [bag, named_table, public]),
    {ok, {}}.

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Msg, State) ->
    {noreply, State}.
    
subscribe(Topic, Pid) ->
    ets:insert(subscribers, {Topic, Pid}).

publish(Topic, Data) ->
    TS = os:timestamp(),
    ets:insert(messages, {Topic, Data, TS}),
    case ets:lookup(subscribers, Topic) of
	[] -> ok;
	SubList ->
	    lists:map(fun({Topic, Pid}) ->
		Pid ! Data
	    end, SubList)
    end.
