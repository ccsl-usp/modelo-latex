# makefile para a compilação do documento

# Essas duas variaveis sao as unicas importantes
BASE_NAME      := tese-exemplo
LATEX          := pdflatex
#LATEX          := lualatex
#LATEX          := xelatex

###############################################################################

OTHERTEXFILES  := $(wildcard *.tex)
BIBFILES       := $(wildcard *.bib)
IMGFILES       := $(wildcard figuras/*)
BIBTEX         := bibtex
MAKEINDEX      := makeindex

all: pdf
default: pdf
pdf: $(BASE_NAME).pdf

$(BASE_NAME).pdf: $(BASE_NAME).tex $(BIBFILES) $(IMGFILES) $(OTHERTEXFILES)
	$(LATEX) $(BASE_NAME)
	$(BIBTEX) $(BASE_NAME)
	$(MAKEINDEX) $(BASE_NAME)
	# We have to run at least makeindex twice...
	$(LATEX) $(BASE_NAME)
	$(BIBTEX) $(BASE_NAME)
	$(MAKEINDEX) $(BASE_NAME)
	@while grep -q 'Rerun to get .* right' *.log; \
                do $(LATEX) $(BASE_NAME); done

clean:
	-rm  -f missfont.log *.bbl *.aux *.log *.toc *.cb *.out \
		*.blg *.brf *.ilg *.ind *.lof *.lot *.idx *.bcf \
		$(BASE_NAME).run.xml $(BASE_NAME).dvi \
		$(BASE_NAME).ps $(BASE_NAME).pdf

.PHONY: all clean
