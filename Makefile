# führt die Tests aus
test:
	prove .

# erzeugt die man-Page
mcalc.1: mcalc.pl doc.pod
	podselect mcalc.pl doc.pod | pod2man > mcalc.1

# Erstellt die Hilfe
help.txt: doc.pod
	podselect -section SYNOPSIS -section OPTIONS -section AUTHOR \
	doc.pod | pod2text -c > help.txt

# erzeugt das Programm
mcalc: mcalc.pl *.pm help.pod help.txt
	pp -a help.txt -o mcalc mcalc.pl

all: mcalc mcalc.1

# aufräumen
clean:
	rm -f help.txt

# alles aufräumen
clean-all:
	rm -f help.txt
	rm -f mcalc
	rm -f mcalc.1