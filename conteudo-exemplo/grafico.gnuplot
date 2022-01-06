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

#### Exemplo com o terminal cairolatex
# Utilize "header" para inserir comandos LaTeX que afetem o texto do
# gráfico como um todo. O tipo e tamanho da fonte são definidos pelo
# LaTeX; "\\scriptsize\\sffamily" são repassados diretamente para
# ele. "fontscale .4" serve apenas para ajudar gnuplot a estimar o
# tamanho do texto.
set terminal cairolatex pdf input size 2.7in,1.8in fontscale .4 header "\\scriptsize\\sffamily"

#### Exemplo com o terminal lua tikz
# Neste caso, usamos "charsize 3.8pt,9pt" (largura média, altura
# média) para ajudar gnuplot a estimar o tamanho do texto.
#set terminal lua tikz size 2.8in,1.8in charsize 3.8pt,9pt font "\\scriptsize\\sffamily"

# Com cairolatex, isso vai gerar também o arquivo figuras/gnuplot.pdf
set output "figuras/gnuplot.tkz"

set xlabel '$x$'
set ylabel '$f(x)$'
set xrange [1:12.5]
set yrange [0:145]
set ytics 25
set key left top # posição da legenda


# "using" porque gnuplot espera os valores absolutos de mínimo
# e máximo, mas estes dados contém o erro para mais/menos.
plot "-" title "$10x-10$" with lines, \
"-" title "$x^2-1$" with linespoints pointtype 1 pointsize .7, \
"-" using 1:2:($2-$3):($2+$4) title "$25\log_2(x)$" with errorlines pointtype 7 pointsize .5
 1.0   0
 2.0  10
 5.0  40
 7.0  60
10.0  90
11.9 109
e
 1.0   0.0
 2.0   3.0
 3.0   8.0
 4.0  15.0
 6.0  35.0
 8.0  63.0
11.9 140.6
e
 1.0  0.00 0.0 0.0
 1.5 14.62 3.1 6.8
 2.0 25.00 5.3 3.8
 3.0 39.62 3.7 6.2
 5.0 58.05 2.2 5.5
 7.0 70.18 3.9 6.6
 8.0 75.00 7.9 2.3
11.9 89.32 7.9 3.8
e
unset output
