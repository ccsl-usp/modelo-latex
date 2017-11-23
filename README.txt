Arquivo LaTeX de exemplo de dissertação/tese a ser apresentados à CPG do IME-USP (Versão 5)

Criação: Jesús P. Mena-Chalco
Revisão: Fabio Kon e Paulo Feofiloff
Data:    Fri Mar  9 22:55:38 BRT 2012

================================================================================
O denominado "formato padrão" aprovado pela CPG refere-se aos itens que devem
estar presentes nas teses/dissertações (e.g. capa, formato de rosto, sumário,
etc.), e não à propia formatação do documento. A critério do aluno pode-se
alterar aspectos como o tamanho de fonte, margens, espaçamento, estilo de
referências, cabeçalho, etc. considerando sempre o bom senso. Por outro lado,
não é necessário que o trabalho seja redigido usando LaTeX, mas é fortemente
recomendado o uso dessa ferramenta.

Leia na seguinte página as especificações dadas pela CPG do IME-USP sobre o
"formato padrão": http://www.ime.usp.br/dcc/posgrad/deposito

================================================================================
Para seu trabalho pode usar uma das seguintes versões:
- Referências em formato ALPHA-IME: diretório 'tese-exemplo-alpha-ime'
- Referências em formato PLAINNAT-IME: diretório 'tese-exemplo-plainnat-ime'

================================================================================
Arquivo principal: 
  -'tese-exemplo.tex'

Arquivos dos capítulos e apêndice:
  - 'cap-introducao.tex'
  - 'cap-conceitos.tex'
  - 'cap-conclusoes.tex'
  - 'ape-conjuntos.tex'

Arquivo de bibliografia: 
  -'bibliografia.bib'

Diretório de figuras: 
  - './figuras/'
  
Compilação do documento:
  - make pdf : usando pdflatex
  - make ps  : usando latex
  Ex:
      $ make pdf
  Obs: Para a compilação do documento que referencia figuras em formato 'ps' ou
       'eps' deve-se usar: 'make ps'

================================================================================
Algumas correções e perguntas frequêntes sobre o padrão estão disponíveis em:
http://www.vision.ime.usp.br/~jmena/stuff/tese-exemplo/

Comentários, dúvidas e/ou sugestões: Jesús P. Mena-Chalco <jmena@vision.ime.usp.br>
