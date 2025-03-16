-module(mapreduce_wordcount_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    mapreduce_wordcount_sup:start_link().

stop(_State) ->
    ok.