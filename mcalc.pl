#!/usr/bin/perl

use parser;
use evaluator;

print "Marc´s calculator v0.0.1\n";

while(1) {
    print "> ";
    my $input = <STDIN>;

    # Leerzeichen entfernen
    $input =~ s/\s//g;
    
    # Sonderbehandlung für 'quit'
    if($input =~ /^(quit|bye|exit)$/) {
	print "bye :)\n";
	exit;
    }

    # parsen
    my $tree = parseTree($input);

    if($tree->value()) {
	# auswerten
	my $result = evaluate($tree);

	printf "%f\n", $result;
    } else {
	# Fehler
	printf ":(\n";
    }
}
