# Authors: Nelson Lago and Jesus P. Mena-Chalco
# This file is distributed under the MIT Licence

THESIS_NAME := tese-exemplo
POSTER_NAME := poster-exemplo
PRESENTATION_NAME := apresentacao-exemplo
ARTICLE_NAME := artigo-exemplo
ALL_TARGETS := $(THESIS_NAME) $(POSTER_NAME) $(PRESENTATION_NAME) $(ARTICLE_NAME)

thesis: $(THESIS_NAME)

poster: $(POSTER_NAME)

presentation: $(PRESENTATION_NAME)

article: $(ARTICLE_NAME)

tese: thesis

apresentacao: presentation

artigo: article

all: $(ALL_TARGETS)

.PHONY: all clean tmpclean distclean tese thesis poster presentation apresentacao article artigo $(ALL_TARGETS)

LATEX := pdflatex
#LATEX := lualatex
#LATEX := xelatex

BIBTEX := biber
#BIBTEX := bibtex

MAKEINDEX := makeindex
#MAKEINDEX := texindy

# Ativando esta opcao, nao e preciso chamar "$(MAKEINDEX) $(BASENAME).idx"
# mais abaixo. Ela nao esta habilitada por padrao porque pode acarretar
# problemas de seguranca
#LATEXOPTS := --shell-escape
LATEXOPTS := -synctex=1 -halt-on-error -file-line-error -interaction nonstopmode -recorder

# Opcoes para makeindex
MAKEINDEXOPTS := -s mkidxhead.ist -l -c

# Opcoes para xindy
# "-C utf8" ou "-M lang/latin/utf8.xdy" sao truques para contornar este
# bug, que existe em outras distribuicoes tambem:
# https://bugs.launchpad.net/ubuntu/+source/xindy/+bug/1735439
# Se "-C utf8" nao funcionar, tente "-M lang/latin/utf8.xdy"
#MAKEINDEXOPTS := -C utf8 -M hyperxindy.xdy
#MAKEINDEXOPTS := -M lang/latin/utf8.xdy -M hyperxindy.xdy

OTHERTEXFILES := $(wildcard *.tex) $(wildcard *.sty) $(wildcard extras/*) $(wildcard conteudo/*)
BIBFILES      := $(wildcard *.bib)
IMGFILES      := $(wildcard figuras/*) $(wildcard logos/*)
# Voce pode acrescentar outras dependencias aqui
MISCFILES     :=

# Arquivos de nomes "$(ALL_TARGETS).$(TMP_EXTENSIONS)" sao apagados
# por "make clean" (juntamente com arquivos "$(ALL_TARGETS).*"
# citados nos arquivos .fls).
TMP_EXTENSIONS := bbl blg ilg ind fls fdb_latexmk

# Arquivos de nomes "$(ALL_TARGETS).*" citados nos arquivos .fls sao
# apagados por make clean.  No entanto, se algo falhar ou o arquivo
# .fls nao for gerado, vamos apagar pelo menos os arquivos com as
# extensoes mais "obvias", ou seja, $(ALL_TARGETS).$(FLS_TMP_EXTENSIONS),
# embora isso em geral seja redundante.
FLS_TMP_EXTENSIONS := log aux bcf idx lof lop lot out run.xml toc

###############################################################################
######## Nada que precise ser modificado pelo usuario daqui para baixo ########
###############################################################################

# Tres maneiras de detectar se estamos rodando em windows. Dependendo
# do ambiente usado para executar make no windows, pode nao ser necessario
# acrescentar a extensao.
ifdef COMSPEC
  LATEX := $(addsuffix .exe,$(LATEX))
  BIBTEX := $(addsuffix .exe,$(BIBTEX))
  MAKEINDEX := $(addsuffix .exe,$(MAKEINDEX))
else
  ifdef SystemRoot
    LATEX := $(addsuffix .exe,$(LATEX))
    BIBTEX := $(addsuffix .exe,$(BIBTEX))
    MAKEINDEX := $(addsuffix .exe,$(MAKEINDEX))
  else
    ifdef SYSTEMROOT
      LATEX := $(addsuffix .exe,$(LATEX))
      BIBTEX := $(addsuffix .exe,$(BIBTEX))
      MAKEINDEX := $(addsuffix .exe,$(MAKEINDEX))
    endif
  endif
endif

# LaTeX e os demais comandos sao executados mais de uma vez e, a cada
# execucao, enviam muitas mensagens para a tela. Vamos tentar reduzir
# isso de duas maneiras: filtrando as mensagens inuteis (com o comando
# abaixo) e mostrando na tela apenas o resultado da ultima execucao de
# cada comando (com o alvo "SHOW_REPORT").
#
# Filtra linhas no formato "(arquivo-da-package-carregada)", que
# comecam com "(" e terminam com uma destas extensoes seguida de ")".
FILTER_MSGS := grep -Eav '(^$$)|(^ *\(.*(sty|ldf|def|cfg|dfu|fd|bbx|cbx|lbx|tex)\)*$$)'

# LaTeX nao se adequa ao modelo de compilacao esperado pelo make, pois ele
# recria os arquivos intermediarios toda vez, impedindo a definicao de regras
# de dependencia simples. Vamos resolver isso em tres etapas:
#
# 1. Utilizamos a opcao "-recorder" do LaTeX para gerar o arquivo .fls, que
#    lista os arquivos gerados por ele durante a compilacao;
# 2. Copiamos os arquivos relevantes (.aux, .toc etc.) a cada execucao para
#    "*-current", mas apenas quando o arquivo gerado for efetivamente
#    diferente; essas copias e que sao de fato utilizadas nas regras de
#    dependencia do make;
# 3. Como make decide a sequencia dos comandos de compilacao no inicio
#    da execucao, ele nao detecta mudancas nos arquivos intermediarios
#    com os quais estamos lidando. Assim, o que fazemos e chamar o make
#    recursivamente para verificar se houve modificacoes nos arquivos. Ou
#    seja, executamos "make", atualizamos os arquivos "*-current"
#    necessarios e executamos make novamente, ate que nao haja mais
#    modificacoes nos arquivos gerados.

# Copia os arquivos gerados pelo LaTeX para "*-current", se for o caso,
# para podermos usar esses arquivos como dependencias para o make. Usamos
# touch aqui porque cp pode nao registrar corretamente o timestamp do
# arquivo copiado.
define REFRESH_TEMP_FILES
$(FIND_TEX_TEMP_FILES) | while read filename; do \
  if ! test -f "$$filename"-current || ! diff -q "$$filename" "$$filename"-current > /dev/null; then \
    cp -f "$$filename" "$$filename"-current 2>/dev/null; touch "$$filename-current"; \
  fi; \
done
endef

# Obtem a lista dos arquivos temporarios gerados pelo proprio
# LaTeX (exceto .log e .pdf, que nao sao dependencias e sao
# modificados toda vez, pois incluem a data de compilacao).
FIND_TEX_TEMP_FILES = grep "^OUTPUT $*" $*.fls 2>/dev/null | tr -d '\r' | cut -f2 -d" " | grep -Ev '\.(log|pdf)$$'
TEX_TEMP_FILES = $(shell $(FIND_TEX_TEMP_FILES))
CURRENT_TEX_TEMP_FILES = $(addsuffix -current,$(TEX_TEMP_FILES))

# LaTeX indica no arquivo de log se e preciso executa-lo novamente;
# por seguranca, vamos checar isso tambem
CHECK_RERUN_MESSAGE = grep -Eaq 'Rerun to get .* right|Please rerun .*[tT]e[xX]|Table widths have changed. Rerun LaTeX|Warning: [Rr]erun [Ll]a[Tt]e[Xx]' $*.log

# Se a compilacao eh rapida, os arquivos "-current" criados mais
# acima podem acabar tendo o mesmo timestamp que o pdf. Para
# resolver isso, usamos o "touch"
define RUN_LATEX
touch timestamp; \
TEXFOT=; \
if texfot --version >/dev/null 2>&1; then \
        TEXFOT=texfot; \
fi; \
msgs="`$$TEXFOT $(LATEX) $(LATEXOPTS) $*`"; \
stat=$$?; \
echo "$$msgs"| $(FILTER_MSGS) > latex-out.log 2>&1; \
if test $$stat -ne 0; then \
	$(SHOW_REPORT); \
	echo; \
	echo "    **** Erro durante a execucao do LaTeX (processando $*) ****"; \
	exit 1; \
fi; \
touch -r timestamp $*.pdf; \
rm -f timestamp
endef

# "make tese-exemplo" -> "make tese-exemplo.pdf"
$(ALL_TARGETS): % : %.pdf

# O arquivo pdf final depende dos arquivos de bibliografia/indice, alem
# dos demais arquivos que compoem o documento e dos arquivos temporarios
# gerados pelo LaTeX na iteracao anterior que foram modificados
.SECONDEXPANSION:

$(addsuffix .pdf,$(ALL_TARGETS)) : %.pdf : %.bbl %.ind $$(CURRENT_TEX_TEMP_FILES) %.tex $(BIBFILES) $(IMGFILES) $(OTHERTEXFILES) $(MISCFILES)
	@if test $(MAKELEVEL) -ge 8; then \
		$(SHOW_REPORT); \
		$(SHOW_LOOP_ERROR); \
		exit 1; \
	fi
	@echo "       Executando $(LATEX) $(LATEXOPTS) $* (iteracao $(MAKELEVEL))..."
	@$(RUN_LATEX)
	@$(REFRESH_TEMP_FILES)
	@echo
	@if $(CHECK_RERUN_MESSAGE); then touch $*.aux-current; fi
	@make -sq $@; result=$$?; \
	if [ $$result -eq 0 ]; then \
		$(SHOW_REPORT); \
		$(SHOW_SUCCESS_MSG); \
	elif [ $$result -eq 1 ]; then \
		make -s $@; \
	else \
		echo "    **** Erro durante a execucao do LaTeX (processando $*) ****"; \
		exit 1; \
	fi

# bitex/biber e makeindex/xindy dependem de arquivos gerados pelo LaTeX
# e, indiretamente, dos proprios arquivos que compoem o documento.
# No entanto, nao vamos declarar essas dependencias aqui. Precisamos
# declarar esta regra apenas para que make saiba como gerar os arquivos
# {idx,bcf}-current no inicio da execucao, quando nenhum arquivo ainda
# foi gerado. Nas iteracoes seguintes, esses arquivos ja existem e, se
# for o caso, sao atualizados pela regra que gera o arquivo pdf. Colocar
# a dependencia aqui nao causa erros, mas em alguns casos faz make
# executar iteracoes desnecessarias.
%.idx-current %.bcf-current:
	@echo "       Executando $(LATEX) $(LATEXOPTS) $* (iteracao auxiliar $(MAKELEVEL))..."
	@$(RUN_LATEX)
	@$(REFRESH_TEMP_FILES)
	@echo

%.ind: %.idx-current
	@echo "       Executando $(MAKEINDEX) $(MAKEINDEXOPTS) $*.idx..."
	@if ! $(MAKEINDEX) $(MAKEINDEXOPTS) $*.idx > makeindex-out.log 2>&1; then \
		$(SHOW_REPORT); \
		echo; \
		echo "    **** Erro durante a execucao do makeindex/xindy (processando $*) ****"; \
		exit 1; \
	fi
	@echo

%.bbl: %.bcf-current $(BIBFILES)
	@echo "       Executando $(BIBTEX) $*..."
	@if ! $(BIBTEX) $* > bibtex-out.log 2>&1; then \
		$(SHOW_REPORT); \
		echo; \
		echo "    **** Erro durante a execucao do bibtex/biber (processando $*) ****"; \
		exit 1; \
	fi
	@echo

clean: tmpclean
	@echo; \
	echo '       Os arquivos PDF gerados *nao* foram apagados; para remove-los, use "make distclean"'; \
	echo;

tmpclean: $(addsuffix -tmpclean,$(ALL_TARGETS))

distclean: tmpclean $(addsuffix -distclean,$(ALL_TARGETS))

%-distclean:
	@echo '       removendo arquivos gerados ($*: pdf, ps, dvi, synctex.gz)'
	-@rm -f $*.ps $*.pdf $*.dvi $*.synctex.gz

%-tmpclean:
	@ echo '       removendo arquivos temporarios ($*: aux, bbl, idx...)'
	-@rm -f timestamp missfont.log \
		mkidxhead.ist mkidxhead.ist-current hyperxindy.xdy hyperxindy.xdy-current \
		latex-out.log makeindex-out.log bibtex-out.log \
		$(TEX_TEMP_FILES) $(CURRENT_TEX_TEMP_FILES) \
		$(foreach ext,$(TMP_EXTENSIONS),$*.$(ext)) \
		$(foreach ext,$(FLS_TMP_EXTENSIONS),$*.$(ext)) \
		$(foreach ext,$(TMP_EXTENSIONS),$*.$(ext)-current) \
		$(foreach ext,$(FLS_TMP_EXTENSIONS),$*.$(ext)-current) \
		$*.ps-current $*.pdf-current $*.dvi-current

define SHOW_REPORT
	if test -f bibtex-out.log; then \
		echo; \
		echo "***********************************************************************"; \
		echo "       Mensagens geradas por bibtex/biber (processando $*) na ultima iteracao:"; \
		echo; \
		cat bibtex-out.log; \
	fi; \
	if test -f makeindex-out.log; then \
		echo; \
		echo "***********************************************************************"; \
		echo "       Mensagens geradas por makeindex/xindy (processando $*) na ultima iteracao:"; \
		echo; \
		cat makeindex-out.log; \
	fi; \
	if test -f latex-out.log; then \
		echo; \
		echo "***********************************************************************"; \
		echo "       Mensagens geradas por LaTeX (processando $*) na ultima iteracao:"; \
		echo; \
		cat latex-out.log; \
	fi
endef

define SHOW_SUCCESS_MSG
	echo; \
	echo; \
	echo "   A compilacao do arquivo $* parece ter terminado com sucesso!"; \
	echo
endef

define SHOW_LOOP_ERROR
	echo; \
	echo "***********************************************************************" >&2; \
	echo "***********************************************************************" >&2; \
	echo "   LaTeX entrou em um laco infinito processando $*;" >&2; \
	echo "   leia a documentacao da package labelschanged" >&2; \
	echo "   (http://ctan.org/pkg/labelschanged )" >&2; \
	echo "***********************************************************************" >&2; \
	echo "***********************************************************************" >&2; \
	echo
endef

# Nao apaga arquivos intermediarios gerados durante a compilacao
.SECONDARY:
