# makefile para a compilacao do documento

BASE_NAME      := tese-exemplo

LATEX          := pdflatex
#LATEX          := lualatex
#LATEX          := xelatex

# Ativando esta opcao, nao e preciso chamar "$(MAKEINDEX) $(BASENAME).idx"
# mais abaixo. Ela nao esta habilitada por padrao porque pode acarretar
# problemas de seguranca
#OPTS           := --shell-escape

#BIBTEX         := bibtex
BIBTEX         := biber

# "-C utf8" e um truque para contornar este bug, que existe em outras
# distribuicoes tambem:
# https://bugs.launchpad.net/ubuntu/+source/xindy/+bug/1735439
#MAKEINDEX      := makeindex
MAKEINDEX      := texindy -C utf8 -M hyperxindy.xdy

###############################################################################

STYLEFILES     := imeusp.sty plainnat-ime.bbx plainnat-ime.cbx
OTHERTEXFILES  := $(wildcard *.tex) $(STYLEFILES)
BIBFILES       := $(wildcard *.bib)
IMGFILES       := $(wildcard figuras/*)

all: pdf
default: pdf
pdf: $(BASE_NAME).pdf

$(BASE_NAME).pdf: $(BASE_NAME).tex $(BIBFILES) $(IMGFILES) $(OTHERTEXFILES)
	$(LATEX) $(OPTS) $(BASE_NAME)
	$(BIBTEX) $(BASE_NAME)
	@while grep -Eq 'Rerun to get .* right|Please rerun .*[tT]e[xX]|Table widths have changed. Rerun LaTeX' *.log || ! test -f *.ind; \
                do $(MAKEINDEX) $(BASE_NAME).idx; \
		$(LATEX) $(OPTS) $(BASE_NAME); done

clean:
	-rm  -f missfont.log *.bbl *.aux *.log *.toc *.cb *.out \
		*.blg *.brf *.ilg *.ind *.lof *.lot *.idx *.bcf \
		$(BASE_NAME).run.xml $(BASE_NAME).dvi \
		$(BASE_NAME).ps $(BASE_NAME).pdf

.PHONY: all clean
