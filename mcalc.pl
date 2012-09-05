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

    my $tree;
    eval {
      # parsen
      $tree = parse($input);

      # auswerten
      my $result = evaluate($tree);

      printf "%.3f\n", $result;
    };
    if(my $error = $@) {
      print $error;
    }
}
