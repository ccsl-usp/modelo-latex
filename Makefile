# Authors: Nelson Lago and Jesus P. Mena-Chalco
# This file is distributed under the MIT Licence

# latexmk em geral eh distribuido junto com o LaTeX e eh o mecanismo
# recomendado para compilar, mas se ele nao estiver disponivel este
# script funciona sem ele.

ifndef USE_LATEXMK
USE_LATEXMK = $(shell if latexmk --version >/dev/null 2>&1; then echo true; else echo false; fi)
#USE_LATEXMK = true
#USE_LATEXMK = false
endif

# Mas por que usar um Makefile para chamar latexmk?
#
# 1. "make" eh mais curto para digitar :-p
#
# 2. Com make, a funcao autocompletar do bash funciona
#
# 3. Eh possivel usar "make all" e "make -j all"
#
# 4. Se for necessario gerar outros arquivos automaticamente para
#    inclusao no documento, eh possivel definir as dependencias e
#    comandos para isso neste arquivo com MISCFILES (mas latexmk
#    pode chamar "make" como parte do processo de compilacao tambem)
#
# 5. Embora latexmk tenha as opcoes -c e -C, elas nao fazem
#    exatamente o que eu gostaria; este arquivo define
#    "make clean" e "make distclean"

# Encontra todos os arquivos .tex. Com isto, a funcao autocompletar do
# bash funciona e podemos fazer "make all"
ALL_TARGETS := $(basename $(wildcard *.tex))

# Por default, compila o primeiro arquivo .tex encontrado
#DEFAULT_TARGET: $(word 1, $(ALL_TARGETS)).pdf
DEFAULT_TARGET: tese.pdf

#SHOW_PDF_AFTER_COMPILATION := true
SHOW_PDF_AFTER_COMPILATION := false

all tudo: $(ALL_TARGETS)


###############################################################################
################################ Dependencias #################################
###############################################################################

# Eh preciso excluir os arquivos *.aux dos subdiretorios para
# compatibilidade com o comando \include de LaTeX.
OTHERTEXFILES := $(wildcard *.tex) $(wildcard *.sty) $(wildcard *.cls) $(wildcard extras/*) $(filter-out %.aux,$(wildcard conteudo/*))
BIBFILES      := $(wildcard *.bib)
IMGFILES      := $(wildcard figuras/*) $(wildcard logos/*)
# Voce pode acrescentar outras dependencias e as suas regras de geracao aqui
MISCFILES     :=


###############################################################################
##### Arquivos temporarios (apagados com "make clean" e "make distclean") #####
###############################################################################

# Extensoes temporarias comuns geradas por programas auxiliares
# do LaTeX (bibtex/biber, makeindex etc.). Arquivos de nomes
# "$(ALL_TARGETS).$(TMP_EXTENSIONS)" sao apagados por "make clean".
TMP_EXTENSIONS := bbl blg ilg ind fls fdb_latexmk

# Extensoes temporarias comuns geradas pelo proprio LaTeX. Arquivos
# de nomes "$(ALL_TARGETS).*" citados nos arquivos .fls sao
# apagados por make clean. No entanto, se algo falhar ou o arquivo
# .fls nao for gerado, vamos apagar pelo menos os arquivos com as
# extensoes mais "obvias", ou seja, $(ALL_TARGETS).$(FLS_TMP_EXTENSIONS),
# embora isso em geral seja redundante.
FLS_TMP_EXTENSIONS := log aux bcf idx lof lop lot out run.xml toc


###############################################################################
######################### Configuracoes de compilacao #########################
###############################################################################

ifndef LATEX
LATEX := pdflatex
#LATEX := lualatex
#LATEX := xelatex
endif

MAKEINDEX := makeindex
#MAKEINDEX := texindy

# Ativando esta opcao, nao e preciso chamar "$(MAKEINDEX) $(BASENAME).idx"
# mais abaixo. Ela nao esta habilitada por padrao porque pode acarretar
# problemas de seguranca
#LATEXOPTS := --shell-escape
LATEXOPTS := -synctex=1 -halt-on-error -interaction batchmode -recorder

# Opcoes para makeindex
MAKEINDEXOPTS := -s mkidxhead.ist -l -c

# Opcoes para xindy
# "-C utf8" ou "-M lang/latin/utf8.xdy" sao truques para contornar este
# bug, que existe em outras distribuicoes tambem:
# https://bugs.launchpad.net/ubuntu/+source/xindy/+bug/1735439
# Se "-C utf8" nao funcionar, tente "-M lang/latin/utf8.xdy"
#MAKEINDEXOPTS := -C utf8 -M hyperxindy.xdy
#MAKEINDEXOPTS := -M lang/latin/utf8.xdy -M hyperxindy.xdy

# Opcoes para bibtex/biber
BIBTEXOPTS :=
BIBEROPTS :=

# O arquivo de configuracao latexmkrc-make eh criado mais abaixo
LATEXMKOPTS := -r latexmkrc-make -dvi- -ps- -pdf -silent

# Nao eh necessario neste modelo, mas pode ser util.
# Veja a secao 5 de "textoc kpathsea" e
# https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files
#export TEXINPUTS := .;extras//;conteudo//;
#export BSTINPUTS := .;extras//;


###############################################################################
######## Nada que precise ser modificado pelo usuario daqui para baixo ########
###############################################################################

# Quase tudo neste arquivo existe para gerir a compilacao sem latexmk:
#
# 1. Arquivo *.checksums
#
# 2. Arquivos latex-out.log, bibtex-out.log, makeindex-out.log
#
# 2. Variaveis LATEX, MAKEINDEX e a deteccao do ambiente windows
#
# 3. Macros que sao comandos (FILTER_MSGS, REFRESH_CHECKSUMS,
#    CHECK_RERUN_MESSAGE, RUN_LATEX, SHOW_REPORT, SHOW_SUCCESS_MSG,
#    SHOW_LOOP_ERROR, COMPILE_WITHOUT_LATEXMK)
#
# 4. As regras para os arquivos .ind, .idx, .bbl, .bcf.
#
# Se sempre exigissemos latexmk, este arquivo seria BEM mais simples
# (na verdade, ele seria desnecessario).

# Obtem a lista dos arquivos temporarios gerados pelo proprio
# LaTeX (exceto .log e .pdf, que nao sao dependencias e sao
# modificados toda vez, pois incluem a data de compilacao).
FIND_TEX_TEMP_FILES = grep -E "^OUTPUT (.*/)?" $*.fls 2>/dev/null | tr -d '\r' | cut -f2 -d" " | grep -Ev '\.(log|pdf)$$'
TEX_TEMP_FILES = $(shell $(FIND_TEX_TEMP_FILES))

# Tres maneiras de detectar se estamos rodando em windows. Dependendo
# do ambiente usado para executar make no windows, pode nao ser necessario
# acrescentar a extensao.
ifdef COMSPEC
  LATEX := $(addsuffix .exe,$(LATEX))
  MAKEINDEX := $(addsuffix .exe,$(MAKEINDEX))
else
  ifdef SystemRoot
    LATEX := $(addsuffix .exe,$(LATEX))
    MAKEINDEX := $(addsuffix .exe,$(MAKEINDEX))
  else
    ifdef SYSTEMROOT
      LATEX := $(addsuffix .exe,$(LATEX))
      MAKEINDEX := $(addsuffix .exe,$(MAKEINDEX))
    endif
  endif
endif

# LaTeX e os demais comandos sao executados mais de uma vez e, a cada
# execucao, enviam muitas mensagens para a tela. Vamos tentar reduzir
# isso de duas maneiras: filtrando as mensagens inuteis (com o comando
# abaixo) e mostrando na tela apenas o resultado da ultima execucao de
# cada comando (com o alvo "SHOW_REPORT").

# Vamos usar texlogsieve se ele estiver disponivel
TEXLOGSIEVE_CMD = $(wildcard texlogsieve)
ifeq ("$(TEXLOGSIEVE_CMD)", "")
    TEXLOGSIEVE_CMD = $(wildcard extras/texlogsieve)
endif

ifneq ("$(TEXLOGSIEVE_CMD)", "")
    TEXLOGSIEVE_CMD := texlua $(TEXLOGSIEVE_CMD)
else
    ifeq ($(shell if texlogsieve --version >/dev/null 2>&1; then echo true; else echo false; fi), true)
        TEXLOGSIEVE_CMD = texlogsieve
    endif
endif

ifneq ("$(TEXLOGSIEVE_CMD)", "")
    TEXLOGSIEVE_CFG = $(wildcard extras/texlogsieverc)
    ifneq ("$(TEXLOGSIEVE_CFG)", "")
        TEXLOGSIEVE_CMD := $(TEXLOGSIEVE_CMD) -c $(TEXLOGSIEVE_CFG)
    endif
endif

ifneq ("$(TEXLOGSIEVE_CMD)", "")
    FILTER_MSGS := $(TEXLOGSIEVE_CMD)
else
    # texlogsieve nao esta disponivel, vamos filtrar "manualmente"
    #
    # Filtra linhas no formato "(arquivo-da-package-carregada)", que
    # comecam com "(" e terminam com uma destas extensoes seguida de ")".
    FILTER_MSGS := grep -Eav '(^$$)|(^ *\(.*(sty|ldf|def|cfg|dfu|fd|bbx|cbx|lbx|tex)\)*$$)'

    # Usamos texfot (script que filtra a saida de LaTeX) se estiver disponivel
    TEXFOT = $(shell if texfot --version >/dev/null 2>&1; then echo texfot --quiet; fi)
endif

# LaTeX nao se adequa ao modelo de compilacao esperado pelo make, pois ele
# recria os arquivos intermediarios toda vez, impedindo a definicao de regras
# de dependencia simples. Vamos resolver isso em tres etapas:
#
# 1. Utilizamos a opcao "-recorder" do LaTeX para gerar o arquivo .fls, que
#    lista os arquivos gerados por ele durante a compilacao;
# 2. Gravamos o md5sum dos arquivos relevantes (.aux, .toc etc.) no arquivo
#    .checksums e apenas modificamos esse arquivo quando algum md5sum é
#    modificado. Os arquivos gerados pelo LaTeX nao fazem parte da lista
#    de dependencias do make, apenas esse arquivo de checksums. Com isso,
#    LaTeX so eh reexecutado quando de fato ha alguma mudanca no conteudo
#    de um desses arquivos.
# 3. Como make decide a sequencia dos comandos de compilacao no inicio
#    da execucao, ele nao detecta mudancas nos arquivos alterados
#    posteriormente, que eh exatamente o caso do arquivo .checksums.
#    Assim, o que fazemos eh chamar o make recursivamente para verificar
#    se houve modificacoes nos arquivos. Ou seja, executamos "make",
#    atualizamos o arquivo .checksums e executamos make novamente, ate
#    que nao haja mais modificacoes nos arquivos gerados.

# Usamos touch aqui porque cp pode nao registrar corretamente o timestamp
# do arquivo copiado.
define REFRESH_CHECKSUMS
$(FIND_TEX_TEMP_FILES) | while read filename; do \
  if ! test -e "$$filename"; then continue; fi; \
  currentsum="`md5sum "$$filename"`"; \
  if ! grep -q "$$currentsum" "$*.checksums"; then \
    sed -i -E -e "/^[0-9a-f]{32}  $$filename"'$$/d' "$*.checksums"; \
    echo "$$currentsum" >> "$*.checksums"; \
  fi; \
done
endef

# LaTeX indica no arquivo de log se e preciso executa-lo novamente;
# por seguranca, vamos checar isso tambem
CHECK_RERUN_MESSAGE = grep -Eaq 'Rerun to get .* right|Please rerun .*[tT]e[xX]|Table widths have changed. Rerun LaTeX|Warning: [Rr]erun [Ll]a[Tt]e[Xx]' $*.log

# Se a compilacao eh rapida, o arquivo .checksums criado mais
# acima pode acabar tendo o mesmo timestamp que o pdf. Para
# resolver isso, usamos o "touch".
define RUN_LATEX
	@touch $*-timestamp
	@export max_print_line=100000; \
	export error_line=254; \
	export half_error_line=238; \
	$(LATEX) $(LATEXOPTS) $* >/dev/null 2>&1; \
	stat=$$?; \
	if test $$stat -ne 0; then \
		$(SHOW_REPORT); \
		$(SHOW_FAIL_MSG); \
	fi; \
	touch -r $*-timestamp $*.pdf; \
	rm -f $*-timestamp; \
	exit $$stat
endef

define COMPILE_WITHOUT_LATEXMK
	@if test $(MAKELEVEL) -ge 8; then \
		$(SHOW_REPORT); \
		$(SHOW_LOOP_ERROR); \
		exit 1; \
	fi
	@echo "       Executando $(LATEX) $(LATEXOPTS) $* (iteracao $(MAKELEVEL))..."
	@$(RUN_LATEX)
	@$(REFRESH_CHECKSUMS)
	@echo
	@if $(CHECK_RERUN_MESSAGE); then touch $*.checksums; fi
	@# result will never be 0: make will always believe there is something \
	to do for the .ind and .bbl files. What happens then is, we'll run make \
	once again, it will run those rules but they will do nothing (because of \
	the checksums), and the rule that calls LaTeX won't be executed (because \
	there are no changes to the .bbl and .ind files).
	@$(MAKE) -sq $@; result=$$?; \
	if [ $$result -eq 0 ]; then \
		exit 0 ; \
	elif [ $$result -eq 1 ]; then \
		$(MAKE) -s $@; \
	else \
		$(SHOW_FAIL_MSG); \
		exit $$result; \
	fi
    @if test $(MAKELEVEL) -eq 0; then \
		$(SHOW_REPORT); \
		$(SHOW_SUCCESS_MSG); \
	fi
endef

define COMPILE_WITH_LATEXMK
	@echo
	@echo "      " Executando latexmk $(LATEXMKOPTS) $*...
	@echo
	@latexmk $(LATEXMKOPTS) $*; \
	result=$$?; \
	if [ $$result -eq 0 ]; then \
		$(SHOW_SUCCESS_MSG); \
	else \
		$(SHOW_FAIL_MSG); \
	fi; \
	exit $$result
endef

# "make target" -> "make target.pdf"
$(ALL_TARGETS): % : %.pdf

ifeq ($(USE_LATEXMK), true)

# Cria arquivo latexmkrc com as opcoes definidas no Makefile
latexmkrc-make: FORCE
	@rm -f latexmkrc-make; \
	echo '$$pdflatex =' "'$(LATEX) $(LATEXOPTS) %O %S';" > latexmkrc-make; \
	echo '$$makeindex =' "'$(MAKEINDEX) $(MAKEINDEXOPTS) %O -o %D %S';" >> latexmkrc-make; \
	echo '$$biber =' "'biber $(BIBEROPTS) %O %S';" >> latexmkrc-make; \
	echo '$$bibtex =' "'bibtex $(BIBTEXOPTS) %O %S';" >> latexmkrc-make; \
	echo '$$recorder = 1;' >> latexmkrc-make; \
	echo '$$cleanup_includes_generated = 1;' >> latexmkrc-make; \
	echo '$$cleanup_includes_cusdep_generated = 1;' >> latexmkrc-make; \
	echo '$$bibtex_use = 2;' >> latexmkrc-make; \
	echo '$$ENV{max_print_line} = $$log_wrap = 100000;' >> latexmkrc-make; \
	echo '$$ENV{error_line} = 254;' >> latexmkrc-make; \
	echo '$$ENV{half_error_line} = 238;' >> latexmkrc-make

# Nao precisamos declarar as dependencias "normais" aqui (arquivos
# .tex, .bib, imagens etc.) porque latexmk cuida disso. Vamos apenas
# usar FORCE para que latexmk seja sempre executado e verifique
# se eh ou nao necessario fazer alguma coisa. Precisamos tambem
# declarar MISCFILES para que as regras necessarias para a geracao
# dos arquivos adicionais sejam executadas antes de chamar latexmk.
%.pdf: $(MISCFILES) latexmkrc-make FORCE
	@$(COMPILE_WITH_LATEXMK)
	@$(SHOW_PDF)

else

# O arquivo pdf final depende dos arquivos de bibliografia/indice, alem
# dos demais arquivos que compoem o documento e dos arquivos temporarios
# gerados pelo LaTeX na iteracao anterior que foram modificados
.SECONDEXPANSION:

$(addsuffix .pdf,$(ALL_TARGETS)) : %.pdf : %.bbl %.ind %.checksums %.tex $(BIBFILES) $(IMGFILES) $(OTHERTEXFILES) $(MISCFILES)
	@$(COMPILE_WITHOUT_LATEXMK)
	@if test $(MAKELEVEL) -eq 0; then \
		$(SHOW_PDF); \
	fi

endif

# bitex/biber e makeindex/xindy dependem de arquivos gerados pelo LaTeX
# e, indiretamente, dos proprios arquivos que compoem o documento.
# No entanto, nao vamos declarar essas dependencias aqui. Precisamos
# declarar esta regra apenas para que make saiba como gerar os arquivos
# {idx,bcf} no inicio da execucao, quando nenhum arquivo ainda foi
# gerado. Nas iteracoes seguintes, esses arquivos ja existem e, se
# for o caso, sao atualizados pela regra que gera o arquivo pdf. Colocar
# a dependencia aqui nao causa erros, mas em alguns casos faz make
# executar iteracoes desnecessarias.
%.idx %.bcf %.checksums:
	@echo "       Executando $(LATEX) $(LATEXOPTS) $* (iteracao auxiliar)..."
	@$(RUN_LATEX)
	@touch "$*.checksums"
	@$(REFRESH_CHECKSUMS)
	@echo

# Os arquivos .idx e .bcf sao gerados novamente a cada iteracao de
# LaTeX; assim, as regras para bibtex/biber e makeindex/xindy serao
# chamadas a cada vez. Vamos permitir isso mas, dentro da regra,
# verificar se eh ou nao o caso de executar o comando.
%.ind: %.idx
	@currentsum="`md5sum "$*.idx"`"; \
	if ! test -f "$*.ind" || ! grep -q "$$currentsum" "$*.checksums"; then \
		sed -i -E -e "/^[0-9a-f]{32}  $*.idx"'$$/d' "$*.checksums"; \
		echo "       Executando $(MAKEINDEX) -q $(MAKEINDEXOPTS) $*.idx..."; \
		if ! $(MAKEINDEX) -q $(MAKEINDEXOPTS) "$*.idx" > /dev/null 2>&1; then \
			$(SHOW_REPORT); \
			echo; \
			echo "    **** Erro durante a execucao do makeindex/xindy (processando $*) ****"; \
			exit 1; \
		fi; \
		echo "$$currentsum" >> "$*.checksums"; \
		echo; \
	fi

%.bbl: %.bcf $(BIBFILES)
	@BIBTEX="bibtex -terse $(BIBTEXOPTS)"; \
	currentsum="USING BIBTEX"; \
	if test -f $*.bcf; then \
		BIBTEX="biber --onlylog $(BIBEROPTS)"; \
		currentsum="`md5sum "$*.bcf"`"; \
	fi; \
	if ! test -f "$*.bbl" || ! grep -q "$$currentsum" "$*.checksums"; then \
		sed -i -E -e "/^[0-9a-f]{32}  $*.bcf"'$$/d' "$*.checksums"; \
		echo "       Executando $$BIBTEX $*..."; \
		if ! $$BIBTEX "$*" > /dev/null 2>&1; then \
			$(SHOW_REPORT); \
			echo; \
			echo "    **** Erro durante a execucao do bibtex/biber (processando $*) ****"; \
			exit 1; \
		fi; \
		echo "$$currentsum" >> "$*.checksums"; \
		echo; \
	fi

clean: tmpclean
	@echo; \
	echo '       Os arquivos PDF gerados *nao* foram apagados; para remove-los, use "make distclean"'; \
	echo;

tmpclean: $(addsuffix -clean,$(ALL_TARGETS))

distclean: $(addsuffix -distclean,$(ALL_TARGETS))

%-distclean: %-clean
	@echo '       removendo arquivos gerados ($*: pdf, ps, dvi, synctex.gz)'
	-@rm -f $*.ps $*.pdf $*.dvi $*.synctex.gz

%-clean:
	@ echo '       removendo arquivos temporarios ($*: aux, bbl, idx...)'
	-@rm -f $*-timestamp latexmkrc-make missfont.log '$*.synctex(busy)' '$*.synctex.gz(busy)' \
		mkidxhead.ist hyperxindy.xdy $*.checksums \
		$*-latex-out.log $*-makeindex-out.log $*-bibtex-out.log \
		$(TEX_TEMP_FILES) \
		$(foreach ext,$(TMP_EXTENSIONS),$*.$(ext)) \
		$(foreach ext,$(FLS_TMP_EXTENSIONS),$*.$(ext))

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

define SHOW_REPORT
	if test -s $*.blg; then \
		echo; \
		echo "***********************************************************************"; \
		echo "       Mensagens geradas por bibtex/biber (processando $*) na ultima iteracao:"; \
		echo; \
		cat $*.blg | sed -e '/You.ve used/,$$d' | grep -E -v INFO ; \
	fi; \
	if test -s $*.ilg; then \
		echo; \
		echo "***********************************************************************"; \
		echo "       Mensagens geradas por makeindex/xindy (processando $*) na ultima iteracao:"; \
		echo; \
		cat $*.ilg | grep -E -v '(This is makeindex, version)|(Scanning style file)|(Scanning input file)|(Sorting entries)|(Generating output file)|(Output written in)|(Transcript written in)|(done.*accepted.*rejected)|(done.*lines written)' ; \
	fi; \
	if test -s $*.log; then \
		echo; \
		echo "***********************************************************************"; \
		echo "       Mensagens geradas por LaTeX (processando $*) na ultima iteracao:"; \
		echo; \
		$(TEXFOT) cat $*.log | $(FILTER_MSGS); \
	fi
endef

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

.PHONY: all clean tmpclean distclean DEFAULT_TARGET FORCE $(ALL_TARGETS)

# Contorna bug/limitacao #53 do bash-completion:
# https://github.com/scop/bash-completion/issues/53
# Este ifeq eh sempre verdadeiro, mas o bash-completion
# nao "percebe" isso e, portanto, tudo funciona :)
ifeq ($(filter npq%,$(firstword $(MAKEFLAGS))),)
# Nao apaga arquivos intermediarios gerados durante a compilacao
.SECONDARY:
endif
