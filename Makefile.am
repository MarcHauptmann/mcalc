dist_bin_SCRIPTS = mcalc
man1_MANS=mcalc.1

TESTS_ENVIRONMENT=$(PROVE) -I src
TESTS=test/evaluator.t test/parser.t

CLEANFILES=$(dict_bin_SCRIPTS) $(man1_MANS) help.txt

# erzeugt die man-Page
mcalc.1: doc/doc.pod
	$(PODTOMAN) doc/doc.pod > mcalc.1

# Erstellt die Hilfe
help.txt: doc/doc.pod
	$(PODTOMAN) -section SYNOPSIS -section OPTIONS -section AUTHOR \
	doc/doc.pod | $(PODTOTEXT) -c > help.txt

# erzeugt das Programm
mcalc: src/mcalc.pl src/*.pm help.txt
	$(PP) -a help.txt -I src -o mcalc src/mcalc.pl
