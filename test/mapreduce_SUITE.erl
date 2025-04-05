-module(mapreduce_SUITE).

-include_lib("eunit/include/eunit.hrl").

-export([
    all/0,
    init_per_suite/1,
    end_per_suite/1,
    init_per_testcase/2,
    end_per_testcase/2
]).

-export([
    single_node_word_count_test/1
]).

all() ->
    [
        single_node_word_count_test
    ].

init_per_suite(Config) ->
    application:ensure_all_started(mapreduce),
    Config.

end_per_suite(Config) ->
    application:stop(mapreduce),
    Config.

init_per_testcase(_TestCase, Config) ->
    mapreduce_test_helper:cleanup_test_directories(),
    {ok, Dirs} = mapreduce_test_helper:create_test_directories(),
    [{test_dirs, Dirs} | Config].

end_per_testcase(_TestCase, Config) ->
    Config.

%% Test cases

single_node_word_count_test(Config) ->
    #{
        input_dir := InputDir,
        input_name := InputName,
        output_dir := OutputDir,
        output_name := OutputName
    } = proplists:get_value(test_dirs, Config),

    TestFiles = [
        {"file1.txt", "hello world\nworld hello\nhello hello"},
        {"file2.txt", "mapreduce test\ntest mapreduce\nerlang"}
    ],
    mapreduce_test_helper:generate_test_files(InputDir, TestFiles),

    {ok, ProcessingId} = mapreduce_server:start_processing(
        mapreduce_wordcount_mapper,
        mapreduce_wordcount_reducer,
        InputName,
        OutputName
    ),

    mapreduce_test_helper:wait_for_completion(ProcessingId),

    Results = lists:sort(mapreduce_test_helper:read_output_files(OutputDir)),
    ExpectedResults = lists:sort([
        {"hello", 4},
        {"world", 2},
        {"mapreduce", 2},
        {"test", 2},
        {"erlang", 1}
    ]),

    ?assertEqual(ExpectedResults, Results).
