#!/bin/sh

pkill -F server.pid

./rebar3 compile
eval "(erl -noshell -pa _build/default/lib/*/ebin -s main -smp enable) &"

pid=$!
echo $pid > server.pid
