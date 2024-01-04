# Authors: Nelson Lago and Jesus P. Mena-Chalco
# This file is distributed under the MIT Licence

# Por que usar um Makefile para chamar latexmk?
#
# 1. "make" eh mais curto para digitar :-p
#
# 2. Com make, a funcao autocompletar do bash funciona
#
# 3. Eh possivel usar "make all" e "make -j all"
#
# 4. Embora latexmk tenha as opcoes -c e -C, elas nao fazem
#    exatamente o que eu gostaria; este arquivo define
#    "make clean" e "make distclean"

# Por default, compila o primeiro arquivo .tex encontrado
#DEFAULT_TARGET: $(word 1, $(basename $(wildcard *.tex))).pdf
DEFAULT_TARGET: tese.pdf

#SHOW_PDF_AFTER_COMPILATION := true
SHOW_PDF_AFTER_COMPILATION := false


###############################################################################
##### Arquivos temporarios (apagados com "make clean" e "make distclean") #####
###############################################################################

# Obtem a lista dos arquivos temporarios gerados pelo proprio LaTeX a
# partir do arquivo .fls (exceto .log e .pdf, que nao sao dependencias
# e sao modificados toda vez, pois incluem a data de compilacao).
FIND_TEX_TEMP_FILES = grep -E "^OUTPUT (.*/)?" $*.fls 2>/dev/null | tr -d '\r' | cut -f2 -d" " | grep -Ev '\.(log|pdf)$$'
TEX_TEMP_FILES = $(shell $(FIND_TEX_TEMP_FILES))

# Se algo falhar e o arquivo .fls nao for gerado, vamos apagar pelo menos
# os arquivos mais "obvios": $(ALL_TARGETS).$(USUAL_TMP_EXTENSIONS)
USUAL_TMP_EXTENSIONS := log aux bcf idx lof lop lot out run.xml toc

# Tambem eh necessario apagar os arquivos gerados por programas auxiliares
# do LaTeX (bibtex/biber, makeindex etc.).
USUAL_TMP_EXTENSIONS := $(USUAL_TMP_EXTENSIONS) bbl blg ilg ind fls fdb_latexmk


###############################################################################
############################# Variaveis adicionais ############################
###############################################################################

# Nao eh necessario neste modelo, mas pode ser util.
# Veja a secao 5 de "textoc kpathsea" e
# https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files
#export TEXINPUTS := .;extras//;conteudo//;
#export BSTINPUTS := .;extras//;


###############################################################################
################################## "funcoes" ##################################
###############################################################################

ifdef LATEX
OPTS := -$(LATEX)
endif

define COMPILE
	@echo
	@echo "      " Executando latexmk $(OPTS) $*...
	@echo
	@latexmk $(OPTS) $*; \
	result=$$?; \
	if [ $$result -eq 0 ]; then \
		$(SHOW_SUCCESS_MSG); \
	else \
		$(SHOW_FAIL_MSG); \
	fi; \
	exit $$result
endef

ifeq ($(SHOW_PDF_AFTER_COMPILATION), true)

define SHOW_PDF
	echo; \
	echo "    Abrindo arquivo $*.pdf..."; \
	echo; \
	xdg-open $*.pdf
endef

else

# Um jeito de dizer "nao faca nada" (melhor que ":")
define SHOW_PDF
	true
endef

endif

define SHOW_SUCCESS_MSG
	echo; \
	echo; \
	echo "   A compilacao do arquivo $* parece ter terminado com sucesso!"; \
	echo
endef

define SHOW_FAIL_MSG
	echo; \
	echo "    **** Erro durante a execucao do LaTeX (processando $*) ****"; \
	exit 1
endef

###############################################################################
############################### As regras em si ###############################
###############################################################################

# Encontra todos os arquivos .tex. Com isto, a funcao autocompletar do
# bash funciona e podemos fazer "make all"
ALL_TARGETS := $(basename $(wildcard *.tex))

all: $(ALL_TARGETS)

# "make target" -> "make target.pdf"
$(ALL_TARGETS): % : %.pdf

# Nao precisamos declarar as dependencias "normais" aqui (arquivos
# .tex, .bib, imagens etc.) porque latexmk cuida disso. Vamos apenas
# usar FORCE para que latexmk seja sempre executado e verifique
# se eh ou nao necessario fazer alguma coisa.
%.pdf: FORCE
	@$(COMPILE)
	@$(SHOW_PDF)

clean: realclean
	@echo; \
	echo '       Os arquivos PDF gerados *nao* foram apagados; para remove-los, use "make distclean"'; \
	echo;

realclean: $(addsuffix -clean,$(ALL_TARGETS))

distclean: $(addsuffix -distclean,$(ALL_TARGETS))

%-distclean: %-clean
	@echo '       removendo arquivos gerados ($*: pdf, ps, dvi, synctex.gz)'
	-@rm -f $*.ps $*.pdf $*.dvi $*.synctex.gz

%-clean:
	@ echo '       removendo arquivos temporarios ($*: aux, bbl, idx...)'
	-@rm -f missfont.log '$*.synctex(busy)' '$*.synctex.gz(busy)' \
		mkidxhead.ist hyperxindy.xdy $(TEX_TEMP_FILES) \
		$(foreach ext,$(USUAL_TMP_EXTENSIONS),$*.$(ext))

.PHONY: all clean realclean distclean DEFAULT_TARGET FORCE $(ALL_TARGETS)

# Isto é um truque sujo para "enganar" o autocomplete do bash,
# veja https://github.com/scop/bash-completion/issues/53
.SECONDARY: DEFAULT_TARGET FORCE realclean
