defmodule Lexer.Parser do
  alias Lexer.Token
  alias Lexer.LeitorArquivo
  use Agent

  @buffer_size 20
  @moduledoc """
  This module make the patter with a piece of string called pattern
  and return a map that represent the token the which match with
  this pattern of lexeme.

  Description of patterns/lexemes/token:

  PATTERN                | TYPE LEXEME       | REPRESENTATION
  -----------------------|-------------------|---------------
  *,/,+,-                | Arith. Op.        | OP_ARIT
  <,<=,>,>=,=,<>         | Relat. Op.        | OP_REL
  E, OU                  | Boolean Op.       | OP_BOOL
  :                      | DELIMITADOR       | OP_DELIM
  (,)                    | Parenthesis       | AP*, *FP
  [:alpha:]+[:alnum:]*   | VARIAVEL          | VAR
  [0-9]+                 | NUMERO INTEIRO    | NUM_INTEIRO
  (\+|\-)?[0-9]+.[0-9]+  | NUMERO REAL       | NUM_REAL
  "[:alnum:]*"           | CADEIA            | STR

  DICLAIMER: This programing language is based in words from portguese brazil,
  this means that tokens and reserved words will coming from portuguese.

  *AP, FP: Open parenthesis, Close parenthesis (abre parenteses, fecha parenteses)
  """

  def start_link(file_name) do
    Agent.start_link(fn -> File.open!(file_name) end, name: Reader)

    Agent.start_link(fn -> %{index: 0, buffer1: next_char(@buffer_size), buffer2: ""} end,
      name: Buffer
    )
  end

  def debug_state() do
    Agent.get(Buffer, fn state -> state end)
  end

  def next_char(qty_char \\ 1) do
    Agent.get(Reader, fn file -> file |> IO.read(qty_char) end)
  end

  def read_from_buffer() do
    symbol =
      Agent.get(Buffer, fn state ->
        if state[:index] < @buffer_size do
          String.at(state[:buffer1], state[:index]) || :eof
        else
          String.at(state[:buffer2], state[:index] - @buffer_size) || :eof
        end
      end)

    advance_buffer_index()

    symbol
  end

  def advance_buffer_index() do
    Agent.update(Buffer, fn state ->
      cond do
        state[:index] < @buffer_size - 1 ->
          %{state | index: state[:index] + 1}

        state[:index] < @buffer_size * 2 - 1 and state[:buffer2] == "" ->
          %{state | buffer2: next_char(@buffer_size), index: state[:index] + 1}

        state[:index] < @buffer_size ->
          %{state | index: state[:index] + 1, buffer2: next_char(@buffer_size)}

        state[:index] < @buffer_size * 2 - 1 ->
          %{state | index: state[:index] + 1}

        true ->
          %{state | index: 0, buffer1: next_char(@buffer_size)}
      end
    end)
  end

  def regress_buffer_index() do
    Agent.update(Buffer, fn state ->
      if state[:index] > 0 do
        %{state | index: state[:index] - 1}
      else
        state
      end
    end)
  end

  def reload_buffer() do
    Agent.update(Buffer, fn _ -> %{index: 0, symbols: next_char(@buffer_size)} end)
  end

  def next_token() do
    case read_from_buffer() do
      "+" ->
        Token.new(:OpAritSoma, "+")

      "-" ->
        Token.new(:OpAritSub, "-")

      "*" ->
        Token.new(:OpAritMult, "*")

      "/" ->
        Token.new(:OpAritDiv, "/")

      "(" ->
        Token.new(:AbrePar, "(")

      ")" ->
        Token.new(:FechaPar, ")")

      ">" ->
        if next_char() == "=" do
          Token.new(:OpRelMaiorIgual, ">=")
        else
          Token.new(:OpRelMaior, ">")
        end

      "<" ->
        look_ahead = next_char()

        cond do
          look_ahead == ">" -> Token.new(:OpRelDif, "<>")
          look_ahead == "=" -> Token.new(:OpRelMenorIgual, "<=")
          true -> Token.new(:OpRelMenor, "<")
        end

      "=" ->
        Token.new(:OpRelIgual, "=")

      ":" ->
        Token.new(:Delim, ":")

      c ->
        c
    end
    |> case do
      c when is_binary(c) -> IO.write(c)
      c -> Token.show(c) |> IO.write()
    end
  end
end
