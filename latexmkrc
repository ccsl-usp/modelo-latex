@default_files = ('tese');

$custom_latex_opts = ' -synctex=1 -halt-on-error -file-line-error -interaction nonstopmode ';

# With older versions of latexmk, this is the recommended
# method for choosing which latex engine to use:
$pdflatex = 'pdflatex' . $custom_latex_opts . '%O %S';
#$pdflatex = 'lualatex' . $custom_latex_opts . '%O %S';
#$pdflatex = 'xelatex' . $custom_latex_opts . '%O %S';

# With newer versions, the previous approach continues to work
# fine (and is probably easier to use!), but you may also use
# the command line options "-lualatex" and "-xelatex", which
# are controlled by these variables (note that they do exist
# on older versions, but work a little differently):
$lualatex = 'lualatex' . $custom_latex_opts . '%O %S';
$xelatex = 'xelatex' . $custom_latex_opts . '%O %S';

# Rodando latexmk a partir do editor atom, texindy falha;
# "2>&1 | tee" é um truque para contornar esse problema
# "-C utf8" ou "-M lang/latin/utf8.xdy" são truques para contornar este
# bug, que existe em outras distribuições tambem:
# https://bugs.launchpad.net/ubuntu/+source/xindy/+bug/1735439
# Se "-C utf8" não funcionar, tente "-M lang/latin/utf8.xdy"
#$makeindex = 'texindy -C utf8 -M hyperxindy.xdy %O -o %D %S 2>&1 | tee';
#$makeindex = 'texindy -M lang/latin/utf8.xdy -M hyperxindy.xdy %O -o %D %S 2>&1 | tee';
$makeindex = 'makeindex -s mkidxhead.ist -l -c %O -o %D %S';

$pdf_mode = 1;
$postscript_mode = $dvi_mode = 0;

$silent = 1;
$silence_logfile_warnings = 1;

# Make latexmk -c/-C clean *all* generated files
$cleanup_includes_generated = 1;
$cleanup_includes_cusdep_generated = 1;
$bibtex_use = 2;
