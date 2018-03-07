# makefile para a compilacao do documento

BASE_NAME := tese-exemplo

LATEX := pdflatex
#LATEX := lualatex
#LATEX := xelatex

# Ativando esta opcao, nao e preciso chamar "$(MAKEINDEX) $(BASENAME).idx"
# mais abaixo. Ela nao esta habilitada por padrao porque pode acarretar
# problemas de seguranca
#OPTS := --shell-escape
OPTS := -synctex=1 -halt-on-error -file-line-error -interaction nonstopmode

#BIBTEX := bibtex
BIBTEX := biber

# "-C utf8" e um truque para contornar este bug, que existe em outras
# distribuicoes tambem:
# https://bugs.launchpad.net/ubuntu/+source/xindy/+bug/1735439
#MAKEINDEX := makeindex
MAKEINDEX := texindy -C utf8 -M hyperxindy.xdy

STYLEFILES    := imeusp.sty plainnat-ime.bbx plainnat-ime.cbx
OTHERTEXFILES := $(wildcard *.tex) $(STYLEFILES)
BIBFILES      := $(wildcard *.bib)
IMGFILES      := $(wildcard figuras/*)


###############################################################################
######## Nada que precise ser modificado pelo usuario daqui para baixo ########
###############################################################################

# LaTeX e os demais comandos sao executados mais de uma vez e, a cada
# execucao, enviam muitas mensagens para a tela. Vamos tentar reduzir
# isso de duas maneiras: filtrando as mensagens inuteis e mostrando na
# tela apenas o resultado da ultima execucao de cada comando.

# Arquivos temporarios que vamos usar para armazenar a saida dos comandos
STDOUT_FILES := latex-out.log bibtex-out.log makeindex-out.log

# Vamos filtrar linhas no formato "(arquivo-da-package-carregada)", que
# comecam com "(" e terminam com uma destas extensoes seguida de ")".
FILTER_MSGS := grep -Eav '(^$$)|(^ *\(.*(sty|ldf|def|cfg|dfu|fd|bbx|cbx|lbx|tex)\)*$$)'

# LaTeX indica no arquivo de log se e preciso executa-lo novamente
CHECK_RERUN := grep -Eaq 'Rerun to get .* right|Please rerun .*[tT]e[xX]|Table widths have changed. Rerun LaTeX' *.log


define run_latex =
	echo "       Executando $(LATEX) $(OPTS) $* (iteração $(1))..."; \
	$(LATEX) $(OPTS) $* | $(FILTER_MSGS) > latex-out.log; \
	echo
endef

define run_bibtex =
	echo "       Executando $(BIBTEX) $*..."; \
	$(BIBTEX) $* > bibtex-out.log; \
	echo
endef

define run_makeindex =
	echo "       Executando $(MAKEINDEX) $*.idx (iteração $$(($(1) - 1)))..."; \
	$(MAKEINDEX) $*.idx > makeindex-out.log 2>&1; \
	echo
endef

define show_report =
	echo; \
	echo "***********************************************************************"; \
	echo "       Mensagens geradas por bibtex/biber:"; \
	echo; \
	cat bibtex-out.log; \
	echo; \
	echo "***********************************************************************"; \
	echo "       Mensagens geradas por makeindex/xindy na última iteração:"; \
	echo; \
	cat makeindex-out.log; \
	echo; \
	echo "***********************************************************************"; \
	echo "       Mensagens geradas por LaTeX na última iteração:"; \
	echo; \
	cat latex-out.log; \
	echo; \
	if test $(1) -ge 8; then \
		echo "***********************************************************************"; \
		echo "***********************************************************************"; \
		echo '   LaTeX entrou em um laço infinito; leia a documentação da package' >&2; \
		echo '   labelschanged (http://ctan.org/pkg/labelschanged )' >&2; \
		echo "***********************************************************************"; \
		echo "***********************************************************************"; \
		echo; \
		exit 1; \
	else \
		echo "***********************************************************************"; \
		echo '   A compilação parece ter terminado com sucesso!'; \
		echo; \
	fi
endef

# LaTeX nao se adequa ao modelo de compilacao esperado pelo make: nao basta
# criar as dependencias, pois as multiplas execucoes atualizam os arquivos,
# confundindo o make. Vamos apenas dividir a compilacao em duas fases: uma
# execucao inicial do LaTeX + bibtex/biber e, se necessario, multiplas
# execucoes seguidas de LaTeX + makeindex/xindy.
# Isso pode gerar mais execucoes que o necessario ou, em raras situacoes,
# inconsistencias, mas em geral funciona adequadamente. Alem disso, e
# relativamente facil acrescentar outros passos (geracao de graficos etc.).

all: $(BASE_NAME).pdf

# Como vamos fazer "cat arquivo" mais abaixo, os arquivos precisam existir
# mesmo que haja erros que interrompam a compilacao no meio.
$(STDOUT_FILES):
	@touch $(STDOUT_FILES)

# Se o arquivo PDF precisa ser atualizado, consideramos que o arquivo .bbl
# tambem precisa ser atualizado (isso nem sempre e verdade, mas nao vamos
# tratar essa possibilidade). Assim, quando esta regra e ativada, LaTeX ja
# foi executado uma vez pela regra do arquivo bbl. Vamos entrar no laco de
# repeticoes apenas se a iteracao anterior nao foi suficiente para
# resolver todas as dependencias *ou* se ainda não foi criado o arquivo do
# indice remissivo.
%.pdf: %.tex $(BIBFILES) $(IMGFILES) $(OTHERTEXFILES) %.bbl
	@set -e; count=2; \
	while test $$count -lt 8 && $(CHECK_RERUN) || ! test -f *.ind; do \
		$(call run_makeindex,$$count); \
		$(call run_latex,$$count); \
		count=$$(( $$count + 1 )); \
	done; \
	$(call show_report,$$count)

# Para gerar o arquivo bbl (bibliografia), vamos executar LaTeX (mesmo que
# talvez nao seja necessario) e bibtex/biber.
%.bbl: %.tex $(BIBFILES) $(OTHERTEXFILES) $(IMGFILES) $(STDOUT_FILES)
	@$(call run_latex,1)
	@$(run_bibtex)

clean:
	-rm  -f missfont.log *.bbl *.aux *.log *.toc *.cb *.out \
		*.blg *.brf *.ilg *.ind *.lof *.lot *.idx *.bcf \
		latex-out.log makeindex-out.log bibtex-out.log *.fls \
		$(BASE_NAME).run.xml $(BASE_NAME).dvi $(BASE_NAME).synctex.gz \
		$(BASE_NAME).fdb_latexmk $(BASE_NAME).ps $(BASE_NAME).pdf

.PHONY: all clean

# Nao apaga arquivos intermediarios gerados durante a compilacao
.SECONDARY:
