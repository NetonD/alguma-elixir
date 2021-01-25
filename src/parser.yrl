Nonterminals
grammar declaracoes lista_declaracoes dcl_variavel tipo instrucoes lista_instrucoes instrucao 
unary_operator expr_arit expr_bool  operando expr_rel
.

Terminals 
delimitador variavel pc_declaracoes pc_inteiro pc_real pc_algoritmo pc_ler
op_arit_soma op_arit_sub op_arit_mult op_arit_div
abre_parenteses fecha_parenteses inteiro real 
op_rel_diferente op_rel_igual op_rel_maior op_rel_maior_igual
op_rel_menor op_rel_menor_igual
pc_atribuir pc_a pc_se pc_entao pc_senao
op_bool_e op_bool_ou 
pc_enquanto pc_inicio pc_fim pc_imprimir
.

Rootsymbol grammar.
Left 80 op_bool_ou.
Left 90 op_bool_e.
Nonassoc 95 op_rel_maior op_rel_maior_igual op_rel_menor op_rel_menor_igual op_rel_igual op_rel_diferente.
Left 100 op_arit_soma.
Left 110 op_arit_sub.
Left 120 op_arit_mult.
Left 130 op_arit_div.
Unary 200 unary_operator.

grammar -> declaracoes instrucoes : {'$1', '$2'}.

%DECLARACOES DE VARIAVEIS 
declaracoes -> delimitador pc_declaracoes lista_declaracoes : {'$2', {'$3'}}.
lista_declaracoes -> dcl_variavel lista_declaracoes : ['$1'] ++ '$2'.
lista_declaracoes -> dcl_variavel : ['$1'].
dcl_variavel -> variavel delimitador tipo: {'$3', '$1'}.
tipo -> pc_inteiro : '$1'.
tipo -> pc_real : '$1'.

%INSTRUCOES DO ALGORITMO
instrucoes -> delimitador pc_algoritmo lista_instrucoes : {'$2', {'$3'}}.
lista_instrucoes -> instrucao lista_instrucoes : ['$1'] ++ '$2'.
lista_instrucoes -> instrucao : ['$1'].

%INSTRUCAO LER 
instrucao -> pc_ler variavel : {'$1', '$2'}.

%INSTRUCAO DE ATRIBUICAO
instrucao -> pc_atribuir expr_arit pc_a variavel : {'$1', '$2', '$4'}.

%INSTRUCAO DE SE-ENTAO-SENAO
instrucao -> pc_se expr_bool pc_entao instrucao : {'$1', '$2', '$4'}.
instrucao -> pc_se expr_bool pc_entao instrucao pc_senao instrucao : {'$1','$2','$4','$5', '$6'}.

%INSTRUCAO ENQUANTO
instrucao -> pc_enquanto expr_bool pc_inicio lista_instrucoes pc_fim : {'$1', '$2', '$4'}.

%INSTRUCAO IMPRIMIR
instrucao -> pc_imprimir variavel : {'$1', '$2'}.

%OPERACOES ARITMETICAS
expr_arit -> expr_arit op_arit_soma expr_arit : {'$2', '$1', '$3'}.
expr_arit -> expr_arit op_arit_mult expr_arit : {'$2', '$1', '$3'}.
expr_arit -> expr_arit op_arit_div expr_arit : {'$2', '$1', '$3'}.
expr_arit -> expr_arit op_arit_sub expr_arit : {'$2', '$1', '$3'}.
expr_arit -> abre_parenteses expr_arit fecha_parenteses : '$2'.
unary_operator -> op_arit_sub expr_arit : {'$1', '$2'}.
unary_operator -> op_arit_soma expr_arit : {'$1', '$2'}.
expr_arit -> variavel : '$1'.
expr_arit -> inteiro : '$1'.
expr_arit -> real : '$1'.
expr_arit -> unary_operator : '$1'.

%OPERACOES RELACIONAIS/BOOLEANAS
expr_bool -> expr_bool op_bool_e expr_bool : {'$2', '$1', '$3'}.
expr_bool -> expr_bool op_bool_ou expr_bool : {'$2', '$1', '$3'}.
expr_bool -> expr_rel : '$1'.
expr_rel -> operando op_rel_igual operando : {'$2', '$1', '$3'}.
expr_rel -> operando op_rel_diferente operando : {'$2', '$1', '$3'}.
expr_rel -> operando op_rel_maior operando : {'$2', '$1', '$3'}.
expr_rel -> operando op_rel_maior_igual operando : {'$2', '$1', '$3'}.
expr_rel -> operando op_rel_menor operando : {'$2', '$1', '$3'}.
expr_rel -> operando op_rel_menor_igual operando : {'$2', '$1', '$3'}.
operando -> inteiro : '$1'.
operando -> real : '$1'.
operando -> variavel : '$1'.

Erlang code.