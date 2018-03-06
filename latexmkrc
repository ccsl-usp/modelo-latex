@default_files = ('tese-exemplo');

$custom_latex_opts = ' -synctex=1 -halt-on-error -file-line-error -interaction nonstopmode ';

$pdflatex = 'pdflatex' . $custom_latex_opts . '%O %S';
#$pdflatex = 'lualatex' . $custom_latex_opts . '%O %S';
#$pdflatex = 'xelatex' . $custom_latex_opts . '%O %S';

$makeindex = 'texindy -C utf8 -M hyperxindy.xdy %O -o %D %S';

$pdf_mode = 1;

$postscript_mode = $dvi_mode = 0;

$silence_logfile_warnings = 1;
