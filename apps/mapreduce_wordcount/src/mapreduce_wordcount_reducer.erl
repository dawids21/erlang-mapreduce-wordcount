-module(mapreduce_wordcount_reducer).
-behaviour(mapreduce_reducer).

-export([reduce/2]).

reduce(_Key, Values) ->
    lists:sum(Values).
