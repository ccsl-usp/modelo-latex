# Docs:
# http://gensoft.pasteur.fr/docs/gnuplot/5.0.4/node425.html
# http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.516
# https://sourceforge.net/p/gnuplot/patches/770/attachment/test-tex-pdflatex.pdf
#
# Importar gráficos gnuplot como imagens no LaTeX tem duas desvantagens:
#
# 1. As fontes usadas no gráfico serão diferentes do documento
#
# 2. Não é possível usar comandos LaTeX dentro do gráfico
#
# gnuplot possui vários "terminais", ou seja, mecanismos de geração
# do gráfico. Vários deles são especialmente voltados para integração
# com LaTeX mas, na prática, apenas dois são recomendados: cairolatex
# e lua tikz.
#
# Com cairolatex, gnuplot gera dois arquivos, um com comandos LaTeX
# para renderizar o texto e um pdf com o gráfico sem textos. No
# LaTeX, basta usar "\input{arquivo-dos-comandos-latex}" e o gráfico
# aparecerá completo no documento. A desvantagem é a geração de dois
# arquivos diferentes.
#
# Com lua tikz, gnuplot gera um arquivo com comandos LaTeX para
# desenhar todo o gráfico, que deve ser inserido no documento LaTeX
# com "\input{arquivo-dos-comandos-latex}". As desvantagens deste método
# são (1) que ele depende de packages LaTeX adicionais que normalmente
# são instaladas pelo gnuplot, não como parte do LaTeX, e (2) que ele
# utiliza muita memória dentro do LaTeX, então o sistema pode falhar
# se houver muitos gráficos (se isso acontecer, utilize lualatex ao
# invés de pdflatex).

# Exemplo com o terminal cairolatex; utilize "header" para inserir
# comandos LaTeX que afetem o texto do gráfico como um todo.
# ATENÇÃO: gnuplot 5.0.5 tem um bug
# (https://sourceforge.net/p/gnuplot/bugs/1945/) que gera um arquivo
# pdf fora do padrão; Ele funciona com pdflatex, mas não com lualatex.
# Para contornar o problema, faça uma conversão de pdf para pdf
# com algum programa. Por exemplo, em Linux:
# pdftocairo -pdf original.pdf corrigido.pdf
# ou
# pdftk original.pdf output corrigido.pdf
set terminal cairolatex pdf input size 3.8in,2.5in header "\\footnotesize"

# Exemplo com terminal lua tikz
#set terminal lua tikz size 3.8in,2.5in font "\\footnotesize"

# Com cairolatex, isso vai gerar também o arquivo figuras/gnuplot.pdf
set output "figuras/gnuplot.tkz"

set xlabel '$\mathit{ordenadas}$'
set ylabel '$\mathit{abscissas}$'

plot "-" title "linear" with linespoints, "-" title "exponencial" with linespoints
1 2
2 3
3 4
4 5
e
1 2
2 4
3 8
4 16
e
unset output
