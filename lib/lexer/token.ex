defmodule Lexer.Token do
  alias Lexer.Token

  @moduledoc """
  Their are valid tokens for syntax for ALGUMA:

  __RESERVED WORDS__
  PCDeclaracoes | PCAlgoritmo | PCInteiro | PCReal | PCAtribuir 
  PCA | PCImprimir | PCSe | PCEntao
  PCEnquanto | PCInicio | PCFim

  __ARITHMETIC OPERATORS__
  OpAritMult | OpAritDiv | OpAritSoma | OpAritSub

  __RELATIONAL OPERATORS__
  OpRelMenor | OpRelMenorIgual | OpRelMaior | OpRelMaiorIgual | OpRelIgual | OpRelDif

  __BOOLEAN OPERATORS__
  OpBoolE | OpBoolOu

  __SPECIAL CHARS__
  Delim | AbrePar | FechaPar

  __TYPES__
  Var | NumInt | NumReal | Cadeia

  __DELIMITER FOR END PROGRAM__
  Fim

  """

  defstruct lexeme: nil, name: nil

  def new(name, lexeme), do: %Token{lexeme: lexeme, name: name}

  def show(%Token{} = token),
    do: ~s(<"#{token.name}", "#{token.lexeme}">)
end
