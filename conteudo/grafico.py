# Docs: https://matplotlib.org/users/pgf.html
#
# Importar gráficos matplotlib como imagens no LaTeX tem duas
# desvantagens:
#
# 1. As fontes usadas no gráfico serão diferentes do documento
#
# 2. Não é possível usar comandos LaTeX dentro do gráfico (mas
#    vale lembrar que matplotlib é capaz de interpretar boa
#    parte dos comandos do modo matemático de LaTeX)
#
# Há três maneiras de integrar matplotlib e LaTeX para melhorar isso:
#
# 1. Definir "text.usetex: True", gerar o gráfico e importar como
#    uma figura pdf. Com isso, matplotlib desenha o gráfico, chama
#    LaTeX internamente para renderizar apenas o texto e "enxerta"
#    esse texto no gráfico. Ainda assim, é preciso "dizer" para
#    matplotlib adicionar os comandos LaTeX necessários para usar
#    as mesmas fontes do documento. Mas não consegui descobrir
#    como misturar fontes com e sem serifa e outras coisinhas.
#
# 2. Ativar o backend pgf de matplotlib, gerar o gráfico e importar
#    como pdf. Neste caso, matplotlib internamente gera um documento
#    LaTeX com comandos específicos para gerar o pdf correspondente.
#    O resultado *deve* ser similar ao anterior e também depende de
#    configurar matplotlib para usar as mesmas fontes do documento.
#    Mas não consegui ativar a fonte monospaced certa e pode não ser
#    fácil acertar o tamanho. Além disso, é preciso copiar tudo que
#    for relevante do preâmbulo LaTeX.
#
# 3. Usar o backend pgf de matplotlib para gerar um arquivo no
#    formato pgf e importar esse arquivo no LaTeX com \input:
#
#    \begin{figure}
#      \centering
#      \input{arquivo.pgf}
#      \caption{blah}
#    \end{figure}
#
#    Neste caso, basta definir se queremos usar a fonte com serifa
#    ou a sem serifa; a fonte correspondente vai seguir o definido no
#    documento e temos acesso a qualquer macro definida no preâmbulo
#    LaTeX do documento sem configuração adicional. A desvantagem é
#    que o processamento do documento pode ficar mais lento.
#
# Abaixo, exemplos de como fazer cada uma dessas opções.

import matplotlib as mpl

################################################################################
#################### Renderizando apenas o texto com LaTeX #####################
################################################################################

# https://matplotlib.org/stable/tutorials/text/usetex.html

#mpl.rcParams.update({
#    "text.usetex": True,
#    "text.latex.preamble": "\\usepackage[T1]{fontenc}\\usepackage{libertinus}\\usepackage[scale=.85]{sourcecodepro}\\usepackage{libertinust1math}",
#})

################################################################################
################## Gerando um pdf usando o backend pgf/LaTeX ###################
################################################################################

# https://matplotlib.org/stable/tutorials/text/pgf.html

# Estas duas linhas fazem a conversão para PDF
# usar o backend PGF (ou seja, LaTeX) ao invés do default
#from matplotlib.backends.backend_pgf import FigureCanvasPgf
#mpl.backend_bases.register_backend('pdf', FigureCanvasPgf)
#
#mpl.rcParams.update({
#    "pgf.texsystem": "lualatex",
#    # Há duas maneiras de configurar as fontes. A primeira é definir
#    # o que for necessário no preâmbulo LaTeX:
#    "pgf.preamble": "\\usepackage[T1]{fontenc}\\usepackage{libertinus}\\usepackage[scale=.85]{sourcecodepro}\\usepackage{libertinust1math}",
#    # Neste caso, é preciso desabilitar a segunda com o comando
#    "pgf.rcfonts": False,
#
#    # A segunda, que é o default, é carregar a package fontspec e
#    # usá-la para configurar as fontes conforme a definição nos
#    # parâmetros "normais" de matplotlib, ou seja, "font.serif",
#    # "font.sans-serif" etc. são convertidos para \setmainfont,
#    # \setsansfont etc. Mas não consegui fazer isto funcionar
#    # corretamente com estas fontes.
#    #"font.serif": "Libertinus Serif",
#    #"font.sans-serif": "Libertinus Sans",
#    #"font.monospace": "SouceCodePro",
#})

################################################################################
#################### Nada especial para gerar arquivos pgf #####################
################################################################################

################################################################################
############################# Comum às três opções #############################
################################################################################

mpl.rcParams.update({
    "font.family": "sans-serif",
    "font.size": "8", # LaTeX com corpo 12pt: \scriptsize=8pt, \footnotesize=10pt
})

################################################################################
########################## Gerando o gráfico de fato ###########################
################################################################################

import matplotlib
import matplotlib.pyplot as plt
import numpy as np

linearX = np.arange(1.0, 12, 0.1)
linearY = 10*linearX -10

quadraticX = np.array([1, 2, 3,  4,  6,  8,  11.90])
quadraticY = np.array([0, 3, 8, 15, 35, 63, 140.61])

logarithmicX = np.array([1,  1.50,  2,  3.00,  5.00,  7.00,  8, 11.90])
logarithmicY = np.array([0, 14.62, 25, 39.62, 58.05, 70.18, 75, 89.32])
logarithmicErrorBars = np.array([
    [0.0, 3.1, 5.3, 3.7, 2.2, 3.9, 7.9, 7.9],
    [0.0, 6.8, 3.8, 6.2, 5.5, 6.6, 2.3, 3.8]
    ])

fig, ax = plt.subplots(figsize=(2.9,1.8)) # polegadas

ax.plot(linearX, linearY,
    linewidth=1,
    label = "$10x-10$")

ax.plot(quadraticX, quadraticY,
    linewidth=1, marker = "+", markersize=5,
    label = "$x^2-1$")

ax.errorbar(logarithmicX, logarithmicY, yerr=logarithmicErrorBars,
    linewidth=1, marker = ".", markersize=5, elinewidth=.5, capsize=2, markeredgewidth=.5,
    label = "$25\log_{2}(x)$")

ax.set(xlabel='$x$', ylabel='$f(x)$')

ax.set_yticks(np.arange(0, 130, step=25))
ax.set_ylim(ymin=0, ymax=145)
ax.set_xlim(xmin=1, xmax=12.5)

ax.legend()

fig.tight_layout()

#plt.savefig("figuras/matplotlib.pdf") # métodos 1 e 2
plt.savefig("figuras/matplotlib.pgf") # método 3
