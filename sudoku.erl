-module(sudoku).
-export([main/0]).

% Function that prints the board and solves it
main() ->
    % Get difficulty level from user
    io:format("Select difficulty level (1 = easy, 2 = medium, 3 = hard): "),
    Level = io:get_line(""),
    case string:trim(Level) of
        "1" -> easy;
        "2" -> medium;
        "3" -> hard;
        _ ->
            io:format("Invalid input. Please enter 1, 2, or 3.~n"),
            easy
    end,
    Board = random_board(Level),
    io:format("Sudoku Board:~n~n"),
    print_board(Board),
    if_solvable(Board, Level).


% Generate a random board based on levels
random_board(Level) ->
    LevelClean = string:trim(Level), % Remove newline from input
    N = case LevelClean of
        "1" -> rand:uniform(9) + 16;      % 17-25 clues
        "2" -> rand:uniform(5) + 21;    % 22-26 clues
        "3" -> rand:uniform(4) + 17       % 18-21 clues
    end,
    EmptyBoard = lists:duplicate(9, lists:duplicate(9, 0)),
    random_fill(EmptyBoard, N, 100). % Limit to 50 retries

random_fill(Board, 0, _) -> Board;
random_fill(Board, N, Retries) ->
    Row = rand:uniform(9) - 1,
    Col = rand:uniform(9) - 1,
    case lists:nth(Col+1, lists:nth(Row+1, Board)) of
        0 ->
            Possible = [X || X <- lists:seq(1,9), is_valid(Board, Row, Col, X)],
            case Possible of
                [] -> random_fill(Board, N, Retries-1); % Try another cell if no valid number
                _ ->
                    Num = lists:nth(rand:uniform(length(Possible)), Possible),
                    NewBoard = set_cell(Board, Row, Col, Num),
                    random_fill(NewBoard, N-1, Retries)
            end;
        _ -> random_fill(Board, N, Retries-1)
    end.

% Makes a formatted Sudoku board
print_board(Board) ->
    lists:foreach(fun({RowIdx, Row}) ->
        % Add a line every 3 rows
        case RowIdx of
            0 -> io:format("+-------+-------+-------+~n");
            3 -> io:format("+-------+-------+-------+~n");
            6 -> io:format("+-------+-------+-------+~n");
            _ -> ok
        end,
        % add dots for empty rows and vertical lines 
        RowStrs = [if N =:= 0 -> "."; true -> integer_to_list(N) end || N <- Row],
        io:format("| ~s ~s ~s | ~s ~s ~s | ~s ~s ~s |~n",
            lists:sublist(RowStrs, 1, 3) ++
            lists:sublist(RowStrs, 4, 3) ++
            lists:sublist(RowStrs, 7, 3)
        )
    end, lists:zip(lists:seq(0,8), Board)),
    io:format("+-------+-------+-------+~n").

% Sudoku solver error handling
if_solvable(Board, Level) ->
    case solve_board(Board) of
        {ok, Solved} ->
            io:format("Solved Sudoku Board:~n~n"),
            print_board(Solved);
        error ->
            io:format("No solution found.~n"),
            io:format("Generating a new board...~n"),
            NewBoard = random_board(Level),
            print_board(NewBoard),
            if_solvable(NewBoard, Level)
    end.

% Backtracking solver
solve_board(Board) ->
    case find_empty(Board) of
        none -> {ok, Board};
        {Row, Col} ->
            Possible_numbers = lists:seq(1,9),
            possible_number(Board, Row, Col, Possible_numbers)
    end.

% Find first empty cell (returns {RowIdx, ColIdx} or none)
find_empty(Board) ->
    find_empty(Board, 0).

find_empty([], _) -> none;
find_empty([Row|Rest], RowIdx) ->
    case lists:member(0, Row) of
        true ->
            ColIdx = find_zero(Row, 0),
            {RowIdx, ColIdx};
        false ->
            find_empty(Rest, RowIdx + 1)
    end.

find_zero([0|_], ColIdx) -> ColIdx;
find_zero([_|Rest], ColIdx) -> find_zero(Rest, ColIdx + 1).

% Try possible numbers for a cell
possible_number(_, _, _, []) -> error;
possible_number(Board, Row, Col, [N|Rest]) ->
    case is_valid(Board, Row, Col, N) of
        true ->
            NewBoard = set_cell(Board, Row, Col, N),
            case solve_board(NewBoard) of
                {ok, Solved} -> {ok, Solved};
                error -> possible_number(Board, Row, Col, Rest)
            end;
        false ->
            possible_number(Board, Row, Col, Rest)
    end.

% Set a cell in the board
set_cell(Board, RowIdx, ColIdx, Val) ->
    lists:map(
        fun({R, I}) ->
            if I =:= RowIdx ->
                lists:map(fun({C, J}) -> if J =:= ColIdx -> Val; true -> C end end,lists:zip(R, lists:seq(0,8))
            );
            true -> R
            end
        end,
        lists:zip(Board, lists:seq(0,8))
    ).

% Check if placing N at (Row, Col) is valid
is_valid(Board, Row, Col, N) ->
    not lists:member(N, lists:nth(Row+1, Board)) andalso
    not lists:member(N, [lists:nth(Col+1, R) || R <- Board]) andalso
    not lists:member(N, get_box(Board, Row, Col)).

% Get 3x3 box for cell
get_box(Board, Row, Col) ->
    BoxRow = (Row div 3) * 3,
    BoxCol = (Col div 3) * 3,
    [lists:nth(C+1, lists:nth(R+1, Board))
     || R <- lists:seq(BoxRow, BoxRow+2),
        C <- lists:seq(BoxCol, BoxCol+2)].

