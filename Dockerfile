FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y biber latexmk texlive-plain-generic texlive-latex-base  \
    texlive-luatex lmodern fonts-lmodern texlive-latex-recommended             \
    texlive-fonts-recommended texlive-latex-extra texlive-fonts-extra          \
    texlive-bibtex-extra texlive-science texlive-lang-english                  \
    texlive-lang-portuguese make
