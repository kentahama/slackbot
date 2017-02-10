#platex frame.tex
dvipdfmx frame.dvi
# convert -density 300 -trim -flatten frame.pdf math.png
convert -density 300 -trim frame.pdf temp.png
convert temp.png  \( +clone -alpha opaque -fill white -colorize 100% \) +swap -geometry +0+0 -compose Over -composite -alpha off math.png

