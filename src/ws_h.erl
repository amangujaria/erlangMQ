-module(ws_h).

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

init(Req, Opts) ->
	{cowboy_websocket, Req, Opts, #{idle_timeout => infinity}}.

websocket_init(State) ->
	erlang:start_timer(1000, self(), <<"ping">>),
	{[], State}.

websocket_handle({text, <<"start">>}, State) ->
        Pid = self(),
        ws_sup:start_child(Pid),
        {[], State};

websocket_handle({text, Msg}, State) ->
        Tokens = binary:split(Msg, <<" ">>, [global]),
        if hd(Tokens) == <<"subscribe">> ->
            Topic = lists:nth(2, Tokens),
            broker:subscribe(Topic, self());
        hd(Tokens) == <<"publish">> ->
            Topic = lists:nth(2, Tokens),
            DataList = lists:sublist(Tokens, 3, length(Tokens)),
            Data = lists:foldl(fun(Elem, Acc) -> 
                if bit_size(Acc) > 0 -> 
                    <<Acc/binary, <<" ">>/binary, Elem/binary>>;
                true -> <<Acc/binary, Elem/binary>> 
                end 
            end, <<>>, DataList),
            broker:publish(Topic, Data);
        true -> ok
        end,
        {[], State};

websocket_handle(Data, State) ->
	{[], State}.

websocket_info({timeout, _Ref, <<"ping">>}, State) ->
	erlang:start_timer(1000, self(), <<"ping">>),
        {[pong], State};

websocket_info({timeout, _Ref, Msg}, State) ->
	{[{text, Msg}], State};

websocket_info(Info, State) ->
        self() ! {timeout, sampleref, Info},
	{[], State}.
