# IME/USP LaTeX Template

A LaTeX template for Masters and PhD/Doctorate dissertations/theses
according to IME/USP guidelines. Note that the actual formatting of
the document (fonts, cover layout, spacing etc.) is *not* mandatory;
the guidelines deal with the document structure only (the [description
of the guidelines](https://www.ime.usp.br/dcc/pos/normas/tesesedissertacoes)
is included in the template). The template is expected to be useful
for unexperienced LaTeX users. Feel free to customize to your needs
and, if appropriate, send us improvements. :)

The [generated PDF file](https://gitlab.com/ccsl-usp/modelo-latex/raw/main/pre-compilados/tese-exemplo.pdf?inline=false)
includes a FAQ, a short (but reasonably
compreehensive) LaTeX tutorial, and some examples of LaTeX commands.
There is also a simple and short [cheat sheet](https://gitlab.com/ccsl-usp/modelo-latex/raw/main/pre-compilados/colinha.pdf?inline=false)
(in Portuguese).

Besides that, there are lots of comments in the .tex and .sty files
about the packages used and things you might want to customize or
learn more about. These comments are in Brazilian Portuguese. Even
if you have some LaTeX experience, you may benefit from skimming the
comments, tutorial, and examples, as they include some useful tips.

You need a reasonably recent working LaTeX installation (TeXLive 2020
works), including biber and biblatex (among other packages). The example
documents may be compiled with `latexmk` and this repo includes compiled
versions of them.

## FAQ

There is a FAQ in the example document and this repo includes a
[compiled version of it in PDF format](https://gitlab.com/ccsl-usp/modelo-latex/raw/main/pre-compilados/tese-exemplo.pdf?inline=false).

## Used packages and installation

There are some instalation instructions in the [example document,
included in this repo in PDF format](https://gitlab.com/ccsl-usp/modelo-latex/raw/main/pre-compilados/tese-exemplo.pdf?inline=false).
The template uses makeindex, biber, and many LaTeX packages.

The template probably includes all packages you'd expect, such as the
AMS packages (amsthm, amsmath etc.), babel, geometry, hyperref, graphicx,
array etc. It also includes many others; in no particular order, these
are directly used in the template:
etoolbox, expl3, xparse, letltxmacro, regexpatch, fontenc, inputenc,
fontspec, fontaxes, unicode-math, calc, ragged2e, microtype, filehook,
indentfirst, footmisc, emptypage, caption, biblatex, setspace, parskip,
xcolor, textcase, fancyhdr, float, flafter, pdflscape, tikz, floatrow,
rotating, subcaption, pdfpages, tablefootnote, longtable, l3keys2e,
multirow, makecell, booktabs, tocbibind, imakeidx, verbatim, mathtools,
csquotes, hypcap, hyperxmp, listings, textcomp, multicol, stfloats, fnpct,
epigraph, todonotes, soul, soulutf8, translator, pgfgantt, tcolorbox,
titlesec, framed, adjustbox, threeparttable, colortbl, fewerfloatpages,
datetime2, iflang, lstautogobble, froufrou, enumitem, contour, siunitx,
pgfplots, appendix, iftex, cancel, and hologo. Several others are
loaded indirectly by these.

The default fonts depend on these packages: lmodern, fix-cm, libertinus,
libertinust1math, fourier-orns, and sourcecodepro.

The example presentation uses beamer, appendixnumberbeamer, qrcode,
and beamertheme-metropolis.

As of 2023, in debian/ubuntu systems, you need to install (with
their dependencies) at least: biber, latexmk, texlive-plain-generic,
texlive-latex-base, texlive-luatex, lmodern, fonts-lmodern,
texlive-latex-recommended, texlive-fonts-recommended, texlive-latex-extra,
texlive-fonts-extra, texlive-bibtex-extra, texlive-science,
texlive-lang-english, and texlive-lang-portuguese. Just run

`sudo apt install biber latexmk texlive-plain-generic texlive-latex-base texlive-luatex lmodern fonts-lmodern texlive-latex-recommended texlive-fonts-recommended texlive-latex-extra texlive-fonts-extra texlive-bibtex-extra texlive-science texlive-lang-english texlive-lang-portuguese`

## Acknowledgements

 * Original version: Jesús P. Mena-Chalco
 * Revision: Fabio Kon and Paulo Feofiloff
 * Latest updates (utf8, biblatex etc.): Nelson Lago

## License

The files that are derived from other projects (natbib-ime.sty,
alpha-ime.bst etc.) are subject to their own licenses. The rest
of the code is available under the MIT License. The example text,
which includes the tutorial and examples, as well as the explanatory
comments in the source, are available under the [Creative Commons
Attribution International Licence, v4.0 (CC-BY 4.0)](https://creativecommons.org/licenses/by/4.0/).
