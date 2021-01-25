defmodule Mix.Tasks.Algumac do
  use Mix.Task
  import AlgumaElixir.Translate
  @shortdoc "testando o mix"
  def run(args) do
    {output_file, _} = args |> List.pop_at(1)
    args
    |> List.first()
    |> lexer()
    |> parser()
    |> take_tree()
    |> translate(output_file)

    binary_name = output_file |> String.split(".") |> List.first()
    System.cmd("g++", [output_file,"-o#{binary_name}"])
  end

  defp lexer(filename) do
    File.read!(filename)
    |> to_charlist()
    |> :lexer.string()
  end

  def parser({:ok, tokens, _line_eof}) do
    tokens
    |> :parser.parse()
  end

  defp take_tree({:ok, tree}), do: tree
end
