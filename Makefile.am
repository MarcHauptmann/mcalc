dist_bin_SCRIPTS = mcalc
man1_MANS=mcalc.1

TESTS_ENVIRONMENT=$(PROVE) -I src
TESTS=test/evaluator.t test/parser.t

# erzeugt die man-Page
mcalc.1: doc/doc.pod
	podselect doc/doc.pod | pod2man > mcalc.1

# Erstellt die Hilfe
help.txt: doc/doc.pod
	podselect -section SYNOPSIS -section OPTIONS -section AUTHOR \
	doc/doc.pod | pod2text -c > help.txt

# erzeugt das Programm
mcalc: src/mcalc.pl src/*.pm help.txt
	pp -a help.txt -I src -o mcalc src/mcalc.pl
