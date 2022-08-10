rm -f *.pdf
rm -f *.tex

pandoc BOOK.md -s -o PU-DV.pdf
pandoc BOOK.md -s -o PU-DV.tex
