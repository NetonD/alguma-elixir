defmodule AlgumaElixir.Translate do

  @operadores_relacionais [:op_rel_diferente, :op_rel_igual, :op_rel_maior, :op_rel_maior_igual, :op_rel_menor, :op_rel_menor_igual]
  @operadores_aritmeticos [:op_arit_soma, :op_arit_mult, :op_arit_sub, :op_arit_div]
  import Alguma.Translate.Utils
  def translate({{:pc_declaracoes, _, _}, arvore_declaracao}), do: translate(arvore_declaracao)
  def translate({lista_declaracoes}) when is_list(lista_declaracoes), do: declarar_variaveis(lista_declaracoes)
  def translate({{:pc_algoritmo, _, _}, arvore_algoritmo}), do: traduzir_instrucoes(arvore_algoritmo)

  def translate({arvore_declaracoes, arvore_algoritmo}, nome_arquivo) do
    arquivo_alvo = File.open!(nome_arquivo, [:write])
    Agent.start_link(fn -> %{scope: %{}, arquivo_alvo: arquivo_alvo} end, name: Semantic)
    escrever_no_arquivo("#include <stdio.h>\n")
    escrever_no_arquivo("#include <stdlib.h>\n")
    escrever_no_arquivo("int main(){\n\n")
    translate(arvore_declaracoes)
    translate(arvore_algoritmo)
    escrever_no_arquivo("\n}")
  end

  def traduzir_instrucoes({lista_instrucoes}) do
    for instrucao <- lista_instrucoes do
      traduzir_instrucao(instrucao)
    end
  end

  def traduzir_instrucao({{:pc_ler, _, _}, {:variavel, _, nome} = variavel} ) do
    if variavel_declarada?(variavel) do
      instrucao_leitura(nome)
    end
  end

  def traduzir_instrucao({{:pc_se, _, _} , condicoes, instrucao}) do
    escrever_no_arquivo("if(")
    traduzir_condicao(condicoes)
    escrever_no_arquivo("){\n\t")
    traduzir_instrucao(instrucao)
    escrever_no_arquivo("}\n")
  end

  def traduzir_instrucao({{:pc_se, _, _} , condicoes, instrucao, {:pc_senao, _, _}, instrucao_senao}) do
    escrever_no_arquivo("if(")
    traduzir_condicao(condicoes)
    escrever_no_arquivo("){\n\t")
    traduzir_instrucao(instrucao)
    escrever_no_arquivo("} else {\n\t")
    traduzir_instrucao(instrucao_senao)
    escrever_no_arquivo("}\n")
  end

  def traduzir_condicao({{:op_bool_ou, _, _}, l, r}) do
    traduzir_condicao(l)
    escrever_no_arquivo("||")
    traduzir_condicao(r)
  end

  def traduzir_condicao({{:op_bool_e, _, _}, l, r}) do
    traduzir_condicao(l)
    escrever_no_arquivo("&&")
    traduzir_condicao(r)
  end

  def traduzir_condicao({{operador, _,_}, {l_tipo, _, l_value} = lhs,{r_tipo, _,r_value} = rhs})
  when operador in @operadores_relacionais do
    if(l_tipo == :variavel,do: variavel_declarada?(lhs))
    if(r_tipo == :variavel,do: variavel_declarada?(rhs))

    case operador do
      :op_rel_igual -> escrever_no_arquivo("(#{l_value} == #{r_value})")
      :op_rel_diferente -> escrever_no_arquivo("(#{l_value} != #{r_value})")
      :op_rel_maior -> escrever_no_arquivo("(#{l_value} > #{r_value})")
      :op_rel_maior_igual -> escrever_no_arquivo("(#{l_value} >= #{r_value})")
      :op_rel_menor -> escrever_no_arquivo("(#{l_value} < #{r_value})")
      :op_rel_menor_igual -> escrever_no_arquivo("(#{l_value} <= #{r_value})")
    end
  end

  def traduzir_instrucao({{:pc_enquanto, _, _}, condicoes, lista_instrucoes}) do
    IO.inspect(lista_instrucoes, pretty: true)
    escrever_no_arquivo("while(")
    traduzir_condicao(condicoes)
    escrever_no_arquivo("){\n")
    traduzir_instrucoes({lista_instrucoes})
    escrever_no_arquivo("}\n")
  end

  def traduzir_instrucao({{:pc_imprimir, _,_}, {:variavel, _, nome} = var}) do
    case tipo_da_variavel(var) do
      :pc_inteiro -> escrever_no_arquivo(~s(printf("%d", #{nome}\);\n))
      _ -> IO.puts "a"
    end
  end

  def traduzir_instrucao({{:pc_atribuir, _, _}, origem, {:variavel, _, _} = var_alvo}) do
    case origem do
      {:variavel, _, _} = var_origem ->
        if variavel_declarada?(var_origem) && variavel_declarada?(var_alvo) do
          instrucao_atribuir(var_origem, var_alvo)
        end
      {:inteiro, _, _} = valor_inteiro ->
        instrucao_atribuir(valor_inteiro, var_alvo)
      {:real, _, _} = valor_real ->
        instrucao_atribuir(valor_real, var_alvo)
      {{op_aritmetico, _, _}, _, _} = expr when op_aritmetico in @operadores_aritmeticos ->
        instrucao_atribuir(expr, var_alvo)
    end
  end

  def instrucao_atribuir({:real, _, _} = valor_origem, {:variavel, l, _} = var_alvo) do
    if tipo_da_variavel(var_alvo) == :pc_real do
      escrever_atribuicao(valor_origem, var_alvo)
    else
      erro_semantico("O tipo da variavel eh incompativel com o valor. Linha #{l}")
    end
  end

  def instrucao_atribuir({:inteiro, _, _} = valor_origem, {:variavel, l, _} = var_alvo) do
    if tipo_da_variavel(var_alvo) == :pc_inteiro do
      escrever_atribuicao(valor_origem, var_alvo)
    else
      erro_semantico("O tipo da variavel eh incompativel com o valor. Linha #{l}")
    end
  end

  def instrucao_atribuir({:variavel, _, _} = var_origem, {:variavel, l, _} = var_alvo) do
    if tipo_da_variavel(var_origem) == tipo_da_variavel(var_alvo) do
      escrever_atribuicao(var_origem, var_alvo)
    else
      erro_semantico("As variaveis sao de tipos diferentes. Linha #{l}")
    end
  end

  def instrucao_atribuir(expr, {_,_, nome} = _var_alvo) do
    escrever_no_arquivo("#{nome} = ")
    traduzir_aritmetica(expr)
    escrever_no_arquivo(";\n")
  end

  def traduzir_aritmetica({{_, _, symbol}, lhs, rhs}) do
    escrever_no_arquivo("(")
    traduzir_aritmetica(lhs)
    escrever_no_arquivo(symbol)
    traduzir_aritmetica(rhs)
    escrever_no_arquivo(")")
  end

  def traduzir_aritmetica({_, _, symbol}), do: escrever_no_arquivo(symbol)

  def escrever_atribuicao({:variavel, _, origem}, {:variavel, _, alvo}) do
    escrever_no_arquivo("#{alvo} = #{origem};\n")
  end

  def escrever_atribuicao({:real, _, valor}, {:variavel, _, alvo}) do
    escrever_no_arquivo("#{alvo} = #{valor};\n")
  end

  def escrever_atribuicao({:inteiro, _, valor}, {:variavel, _, alvo}) do
    escrever_no_arquivo("#{alvo} = #{valor};\n")
  end

  def instrucao_leitura(nome) do
    arquivo = Agent.get(Semantic, fn state -> state[:arquivo_alvo] end)
    variavel =
      Agent.get(Semantic, fn state -> Map.get(state[:scope], :variaveis) end)
      |> Enum.find(fn %{nome: n} -> nome == n end)

    case variavel do
      %{tipo: :pc_inteiro} -> IO.write(arquivo, ~s(scanf("%d", &#{nome}\);\n))
      %{tipo: :pc_real} -> IO.write(arquivo, ~s(scanf("%f", &#{nome}\);\n))
    end
  end

  def declarar_variaveis(lista_variaveis) do
    variaveis =
      for variavel <- lista_variaveis do
        {{tipo, _, _}, {_, _, nome}} = variavel
        %{tipo: tipo, nome: nome}
      end
    escrever_declaracoes(variaveis)
    Agent.update(Semantic, fn state -> %{state | scope: %{variaveis: variaveis}} end)
  end

  defp escrever_declaracoes(variaveis) do
    Enum.map(variaveis, fn var ->
      case var do
        %{tipo: :pc_inteiro, nome: nome} -> escrever_no_arquivo("int #{nome};\n")
        %{tipo: :pc_real, nome: nome} -> escrever_no_arquivo("int #{nome};\n")
      end
    end)
  end

  # def translate(tree), do: IO.inspect(tree)
end
