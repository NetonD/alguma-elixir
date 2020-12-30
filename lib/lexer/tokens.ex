defmodule Lexer do
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

  defp read_file(file_name) do
    File.stream!(file_name)
    |> Stream.map(fn line -> IO.inspect(line) end)
    |> Stream.run()
  end
end
