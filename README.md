# IME/USP LaTeX Template

A LaTeX template for Masters and PhD dissertations/theses according to
IME/USP guidelines. Feel free to customize to your needs and, if
appropriate, send us improvements. :)

You need a working LaTeX installation, including xindy, biber and biblatex
(among other packages). The document may be compiled with "make" and this
repo includes a compiled version of it. There are lots of comments on the
"tese-exemplo.tex" file about the packages used and things you might want
to customize or learn more about. These comments are in Brazilian Portuguese.

## Acknowledgements

 * Original version: Jesús P. Mena-Chalco
 * Revision: Fabio Kon and Paulo Feofiloff
 * Latest updates (utf8, biblatex etc.): Nelson Lago

## TODO

 * Recent biblatex versions (2017) use "labeldate+extradate" instead of
   "labelyear+extrayear"; in a couple of years we should modify the
   files plainnat-ime.bbx and plainnat-ime.cbx accordingly.

 * The translated version of the natbib package included in the template
   is old; we should update it.

## License

The files that are derived from other projects (natbib-ime.sty,
alpha-ime.bst etc.) are subject to their own licenses. The rest
of the code is available under the MIT License.
