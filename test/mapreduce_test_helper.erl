-module(mapreduce_test_helper).

-export([
    create_test_directories/0,
    cleanup_test_directories/0,
    write_test_file/2,
    generate_test_files/2,
    read_output_files/1,
    wait_for_completion/1
]).

create_test_directories() ->
    {ok, PublicDir} = application:get_env(mapreduce, public_directory),
    InputDir = filename:join(PublicDir, "input"),
    ok = filelib:ensure_dir(filename:join(InputDir, "dummy")),

    OutputDir = filename:join(PublicDir, "output"),
    ok = filelib:ensure_dir(filename:join(OutputDir, "dummy")),

    {ok, #{
        input_dir => InputDir,
        input_name => "input",
        output_dir => OutputDir,
        output_name => "output"
    }}.

cleanup_test_directories() ->
    {ok, PublicDir} = application:get_env(mapreduce, public_directory),
    file:del_dir_r(PublicDir).

write_test_file(FilePath, Content) ->
    ok = filelib:ensure_dir(FilePath),
    ok = file:write_file(FilePath, Content).

generate_test_files(InputDir, FileContents) ->
    lists:foreach(
        fun({Filename, Content}) ->
            FilePath = filename:join(InputDir, Filename),
            write_test_file(FilePath, Content)
        end,
        FileContents
    ).

read_output_files(OutputDir) ->
    {ok, Files} = file:list_dir(OutputDir),
    lists:foldl(
        fun(File, Acc) ->
            FilePath = filename:join(OutputDir, File),
            {ok, Content} = file:read_file(FilePath),
            Lines = string:tokens(binary_to_list(Content), "\n"),
            lists:foldl(
                fun(Line, LineAcc) ->
                    case string:tokens(Line, "\t") of
                        [Word, CountStr] ->
                            [{Word, list_to_integer(CountStr)} | LineAcc];
                        _ ->
                            LineAcc
                    end
                end,
                Acc,
                Lines
            )
        end,
        [],
        Files
    ).

wait_for_completion(ProcessingId) ->
    case mapreduce_server:check_processing(ProcessingId) of
        {ok, finished} ->
            ok;
        {ok, _} ->
            timer:sleep(100),
            wait_for_completion(ProcessingId);
        {error, Reason} ->
            ct:fail("Processing failed: ~p", [Reason])
    end.
