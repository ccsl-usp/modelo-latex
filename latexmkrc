@default_files = ('tese');

# TeXLive até no mínimo 2023 produz PDFs identificados como versão 1.5.
# Ao incorporar arquivos PDF de imagem com versões mais novas, isso faz
# LaTeX gerar um warning. Como na prática isso não causa problemas e não
# há boas razões para manter a versão em 1.5, redefinimos aqui para 1.7.

# Compilação "normal"
#set_tex_cmds('-synctex=1 -halt-on-error %O %S');


# Compilação forçando manualmente a versão do pdf para 1.7
#set_tex_cmds('-synctex=1 -halt-on-error %O %P');
#$pre_tex_code =   '\ifdefined\pdfminorversion\pdfminorversion=7\fi'
#                . '\ifdefined\pdfvariable\pdfvariable minorversion 7\fi'
#                . '\ifdefined\XeTeXrevision\special{pdf:minorversion 7}\fi';


# Compilação forçando a versão do pdf para 1.7 com a package bxpdfver
set_tex_cmds('-synctex=1 -halt-on-error -jobname=%A %O %P');
$pre_tex_code = '\RequirePackage[1.7]{bxpdfver}';


# Nao eh necessario neste modelo, mas pode ser util.
# Veja a secao 5 de "textoc kpathsea" e
# https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files
#ensure_path('TEXINPUTS', 'conteudo//');
#ensure_path('TEXINPUTS', 'extras//');
#ensure_path('TEXINPUTS', '.');
#ensure_path('BSTINPUTS', 'extras//');
#ensure_path('BSTINPUTS', '.');

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

$silent = 1; # This adds "-interaction batchmode"
$silence_logfile_warnings = 1;
$rc_report = 0;

# Make latexmk -c/-C clean *all* generated files
$cleanup_includes_generated = 1;
$cleanup_includes_cusdep_generated = 1;
$bibtex_use = 2;

# https://tex.stackexchange.com/a/384153
$ENV{max_print_line} = $log_wrap = 100000;
$ENV{error_line} = 254;
$ENV{half_error_line} = 238;

END {
  local $?; # do not override previous exit status
  if (-e "$root_filename.blg" and open my $bibfile, '<', "$root_filename.blg") {
      print("**********************\n");
      print("bibtex/biber messages:\n\n");

      my $showed_something = 0;
      while(my $line = <$bibfile>) {
          if ($line =~ /You.ve used/) {
              last;
          } elsif ($line =~ /INFO/) {
              next;
          } else {
              print($line);
              $showed_something = 1;
          };
      };
      close($bibfile);

      if ($showed_something) {
          print("\n");
      } else {
          print("No important messages to show\n\n");
      };
  };

  if (-e "$root_filename.ilg" and open my $indfile, '<', "$root_filename.ilg") {
      print("*************************\n");
      print("makeindex/xindy messages:\n\n");

      my $showed_something = 0;
      while(my $line = <$indfile>) {
          if ($line =~ /This is makeindex, version/
                  or $line =~ /Scanning style file/
                  or $line =~ /Scanning input file/
                  or $line =~ /Sorting entries/
                  or $line =~ /Generating output file/
                  or $line =~ /Output written in/
                  or $line =~ /Transcript written in/
                  or $line =~ /done.*accepted.*rejected/
                  or $line =~ /done.*lines written/
          ) {
              next;
          } else {
              print($line);
              $showed_something = 1;
          };
      };
      close($indfile);

      if ($showed_something) {
          print("\n");
      } else {
          print("No important messages to show\n\n");
      };
  };

  if (-e "$root_filename.log") {
      print("***************\n");
      print("LaTeX messages:\n\n");

      my $cmd = "";
      my $givenpath = File::Spec->catfile('extras', 'texlogsieve');
      if (-s 'texlogsieve') {
          $cmd = 'texlua texlogsieve';
      } elsif (-s $givenpath) {
          $cmd = 'texlua' . ' ' . $givenpath;
      } else {
          my $nothing = `texlogsieve -h 2>&1`;
          if ($? == 0) {
              $cmd = 'texlogsieve';
          };
      };

      my $showed_something = 0;
      if ($cmd ne "") {
          my $conffile = File::Spec->catfile('extras', 'texlogsieverc');
          if (-e $conffile) { $cmd = $cmd . ' -c ' . $conffile; };
          Run_subst($cmd . ' %R.log');
          $showed_something = 1;
      } elsif (open my $logfile, '<', "$root_filename.log") {
          while (my $line = <$logfile>) {
              print($line);
              $showed_something = 1;
          };
          close($logfile);
      };

      if ($showed_something) {
          print("\n");
      } else {
          print("No important messages to show\n\n");
      }
  };
};
