defmodule Alguma.Translate.Utils do

  def variavel_declarada?({:variavel, linha, nome}) do
    Agent.get(Semantic, fn state -> Map.get(state[:scope], :variaveis) end)
    |> Enum.find(fn %{nome: n} -> nome == n end)
    |> case  do
      nil -> erro_semantico("Variavel #{nome} na linha #{linha} nao declarada.")
      var -> var
    end
  end

  def erro_semantico(mensagem) do
    raise mensagem
  end

  def tipo_da_variavel({:variavel, _, nome}) do
    Agent.get(Semantic, fn state -> Map.get(state[:scope], :variaveis) end)
    |> Enum.find(fn %{nome: n} -> nome == n end)
    |> IO.inspect()
    |> Map.get(:tipo)
  end

  def escrever_no_arquivo(string) do
    Agent.get(Semantic, fn state -> state[:arquivo_alvo] end)
    |> IO.write(string)
  end
end
