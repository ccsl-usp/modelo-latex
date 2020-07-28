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

set xlabel '$x$'
set ylabel '$f(x)$'

plot "-" title "linear ($10x-10$)" with lines, "-" title "quadrático ($x^2-1$)" with lines, "-" title "logarítmico ($25\log_2(x)$)" with lines
0
3
6
9
12
15
18
21
24
27
30
33
36
39
42
45
48
51
54
57
60
63
66
69
72
75
78
81
84
87
90
93
96
99
102
105
108
e
0
0.69
1.56
2.61
3.84
5.25
6.84
8.61
10.56
12.69
15
17.49
20.16
23.01
26.04
29.25
32.64
36.21
39.96
43.89
48
52.29
56.76
61.41
66.24
71.25
76.44
81.81
87.36
93.09
99
105.1
111.4
117.8
124.4
131.3
138.2
e
0
9.463
16.95
23.15
28.44
33.05
37.14
40.81
44.14
47.19
50
52.61
55.04
57.32
59.46
61.49
63.4
65.22
66.95
68.6
70.18
71.7
73.15
74.55
75.89
77.19
78.44
79.65
80.82
81.95
83.05
84.11
85.15
86.16
87.14
88.09
89.02
unset output
