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
#    formato pgf e importar esse arquivo no LaTeX com \input. Nesse
#    caso, basta definir se queremos usar a fonte com serifa ou sem
#    serifa, a fonte e o tamanho vão seguir o definido no documento
#    e temos acesso a qualquer macro definida no preâmbulo LaTeX do
#    documento sem configuração adicional. A desvantagem é que o
#    processamento do documento pode ficar mais lento.
#
# Abaixo, exemplos de como fazer cada uma dessas opções.

import matplotlib as mpl

################################################################################
##################### Renderizando apenas o texto com LaTeX ####################
################################################################################

#mpl.rcParams.update({
#    "text.usetex": True,
#    # Não esqueça de definir as strings como u"blah"
#    "text.latex.unicode": True,
#    "text.latex.preamble": [
#        "\\usepackage[utf8]{inputenc}",
#        "\\usepackage[T1]{fontenc}",
#        "\\usepackage{lmodern}",
#        "\\usepackage{inconsolata}",
#        "\\usepackage[mono=false]{libertine}",
#        "\\usepackage[libertine]{newtxmath}",
#        "\\useosf",
#    ],
#    "font.family": "serif",
#    "font.size": "10",
#})

################################################################################
################### Gerando um pdf usando o backend pgf/LaTeX ##################
################################################################################

# Estas duas linhas fazem a conversão para PDF
# usar o backend PGF (ou seja, LaTeX) ao invés do default
#from matplotlib.backends.backend_pgf import FigureCanvasPgf
#mpl.backend_bases.register_backend('pdf', FigureCanvasPgf)
#
#mpl.rcParams.update({
#    "pgf.texsystem": "lualatex",
#    # Há duas maneiras de configurar as fontes. A primeira é definir
#    # o que for necessário no preâmbulo LaTeX:
#    "pgf.preamble": [
#        "\\usepackage[utf8]{inputenc}",
#        "\\usepackage[T1]{fontenc}",
#        "\\usepackage{lmodern}",
#        "\\usepackage{inconsolata}",
#        "\\usepackage[mono=false]{libertine}",
#        "\\usepackage[libertine]{newtxmath}",
#        "\\useosf",
#    ],
#    # Neste caso, é preciso desabilitar a segunda com o comando
#    "pgf.rcfonts": False,
#    # A segunda, que é o default, é carregar a package fontspec e
#    # usá-la para configurar as fontes conforme a definição nos
#    # parâmetros "normais" de matplotlib, ou seja, "font.serif",
#    # "font.sans-serif" etc. são convertidos para \setmainfont,
#    # \setsansfont etc.
#    #"font.serif": "Linux Libertine O",
#    #"font.sans-serif": "Linux Biolinum O",
#    #"font.monospace": "Inconsolata",
#    "font.family": "serif",
#    "font.size": "10",
#})

################################################################################
######################## Nada especial para arquivos pgf #######################
################################################################################

mpl.rcParams.update({
    "font.family": "serif",
    "font.size": "9",
})

################################################################################
########################### Gerando o gráfico de fato ##########################
################################################################################

import matplotlib.pyplot as plt

# figsize in inches
plt.figure(figsize=(1.5,2.5))
plt.margins(0)
plt.xticks(range(1,4), (u"SP", u"RJ", u"MG"))
plt.bar([1,2,3],[2,6,4])
plt.xlabel(u"\\textit{Estado}")
plt.ylabel(u"$\\mu$")
plt.tight_layout(0.1)

#plt.savefig("figuras/matplotlib.pdf") # métodos 1 e 2
plt.savefig("figuras/matplotlib.pgf") # método 3
