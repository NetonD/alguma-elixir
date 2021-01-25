Definitions.

LETRA_MINUSCULA = [a-z]
LETRA_MAIUSCULA = [A-Z]
LETRA = [a-zA-z]
DIGITO = [0-9]
IGNORADOS = \n|\s|\t
COMENTARIO = \%(.*|\s*)*
Rules.

%OPERADORES ARITIMETICOS
\+ : {token, {op_arit_soma, TokenLine, TokenChars}}.
\- : {token, {op_arit_sub, TokenLine, TokenChars}}.
\* : {token, {op_arit_mult, TokenLine, TokenChars}}.
\\ : {token, {op_arit_div, TokenLine, TokenChars}}.

%INTEIRO
{DIGITO}+ : {token, {inteiro, TokenLine, list_to_integer(TokenChars)}}.
%REAL
{DIGITO}+\.{DIGITO}+ : {token, {real, TokenLine, list_to_float(TokenChars)}}.
%PARENTESES
\( : {token, {abre_parenteses, TokenLine, TokenChars}}.
\) : {token, {fecha_parenteses, TokenLine, TokenChars}}.
%DELIMITADOR
\: : {token, {delimitador, TokenLine, TokenChars}}.
%CADEIA DE CARACTERES
\'(.*)\' : {token, {cadeia, TokenLine, TokenChars}}.

%PALAVRAS RESERVADAS
DECLARACOES : {token, {pc_declaracoes, TokenLine, TokenChars}}.
ALGORITMO : {token, {pc_algoritmo, TokenLine, TokenChars}}.
INTEIRO : {token, {pc_inteiro, TokenLine, TokenChars}}.
REAL : {token, {pc_real, TokenLine, TokenChars}}.
ATRIBUIR : {token, {pc_atribuir, TokenLine, TokenChars}}. 
A : {token, {pc_a, TokenLine, TokenChars}}.
LER : {token, {pc_ler, TokenLine, TokenChars}}.
IMPRIMIR : {token, {pc_imprimir, TokenLine, TokenChars}}.
SE : {token, {pc_se, TokenLine, TokenChars}}.
ENTAO : {token, {pc_entao, TokenLine, TokenChars}}.
SENAO : {token, {pc_senao, TokenLine, TokenChars}}.
ENQUANTO : {token, {pc_enquanto, TokenLine, TokenChars}}.
INICIO : {token, {pc_inicio, TokenLine, TokenChars}}.
FIM : {token, {pc_fim, TokenLine, TokenChars}}. 

%OPERADORES RELACIONAIS
\>= : {token, {op_rel_maior_igual, TokenLine,TokenChars}}.
\<= : {token, {op_rel_menor_igual, TokenLine,TokenChars}}.
\< : {token, {op_rel_menor, TokenLine,TokenChars}}.
\> : {token, {op_rel_maior, TokenLine,TokenChars}}.
\= : {token, {op_rel_igual, TokenLine, TokenChars}}.
\<\> : {token, {op_rel_diferente, TokenLine, TokenChars}}.
%OPERADORES BOOLEANOS
E : {token, {op_bool_e, TokenLine, TokenChars}}.
OU : {token, {op_bool_ou, TokenLine, TokenChars}}.

%VARIAVEL
{LETRA_MINUSCULA}+({LETRA}+|{DIGITO}+)* : {token, {variavel, TokenLine, TokenChars}}.

{IGNORADOS} : skip_token.
{COMENTARIO} : skip_token.

Erlang code. 