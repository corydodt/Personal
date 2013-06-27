all: corydodt.html corydodt.pdf

corydodt.html: corydodt.txt resume.css
	rst2html --stylesheet-path=resume.css corydodt.txt corydodt.html

corydodt.pdf: corydodt.txt resume.css
	rst2pdf -s resume.css corydodt.txt 

clean:
	rm -f corydodt.html corydodt.pdf 
