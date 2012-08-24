#!/usr/bin/perl

use parser;
use evaluator;

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
    $matches = parse($input);

    if($matches) {
	# auswerten
	my $result = evaluate($input);

	printf "%f\n", $result;
    } else {
	# Fehler
	printf ":(\n";
    }
}
