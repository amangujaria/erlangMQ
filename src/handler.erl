-module(handler).

-export([init/2, allowed_methods/2, content_types_provided/2, db_to_json/2]).
-export([content_types_accepted/2, text_to_db/2]).
-record(state, {op}).

init(Req, Opts) ->
    [Op | _] = Opts,
    State = #state{op=Op},
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    Methods = [<<"GET">>, <<"POST">>],
    {Methods, Req, State}.

content_types_provided(Req, State) ->
    {[
      {<<"application/json">>, db_to_json}
     ], Req, State}.

content_types_accepted(Req, State) ->
    {[
      {<<"text/plain">>, text_to_db},
      {<<"application/x-www-form-urlencoded">>, text_to_db}
     ], Req, State}.

db_to_json(Req, #state{op=Op} = State) ->
    {Body, Req1, State1} = get_one_record(Req, State),
    {Body, Req1, State1}.

get_one_record(Req, State) ->
    OpValues = case State#state.op of
        {list, queues} ->
            Queues = lists:map(fun(Elem) -> binary_to_list(Elem) end, proplists:get_keys(ets:tab2list(messages))),
            [{"queues", io_lib:format("~p", [Queues])}];
        {list, quantity} ->
            Queues = proplists:get_keys(ets:tab2list(messages)),
            Messages = ets:tab2list(messages),
            lists:map(fun(Queue) ->
                {binary_to_list(Queue), integer_to_list(length(lists:filter(fun({Topic, _, _}) -> Topic == Queue end, Messages)))}
            end, Queues);
        _ -> [{"not found", "not found"}]
    end,
    AccBody = lists:foldl(fun({Item, Value}, Acc) ->
        io_lib:format("{\"" ++ Item ++ "\": \"" ++ Value++ "\"}", []) ++ "\n" ++ Acc
    end, "", OpValues),
    {list_to_binary(AccBody), Req, State}.

text_to_db(Req, #state{op=Op} = State) ->
    Body = case Op of
        create ->
            io_lib:format("{\"create\": \"created\"}", []);
        delete ->
            io_lib:format("{\"delete\": \"deleted\"}", []);
        update ->
            io_lib:format("{\"update\": \"updated\"}", [])
    end,
    Req1 = cowboy_req:set_resp_body(list_to_binary(Body), Req),
    {true, Req1, State}.

process_post(Req, State) ->
  case cowboy_req:has_body(Req) of
    true ->
      {ok, Body, Req2} = cowboy_req:body(Req),
      Req3 = cowboy_req:set_resp_body(Body, Req2),
      {true, Req3, State};
    false ->
      {false, Req, State}
  end.
