-module(mapreduce_wordcount_mapper).

-behaviour(mapreduce_mapper).

-export([map/1]).

map(Input) ->
    [
        {Word, 1}
     || Word <- string:tokens(string:trim(Input), " "),
        string:trim(Word) =/= ""
    ].
