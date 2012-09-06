#!/usr/bin/perl

use parser;
use evaluator;
use Term::ReadLine;

print "Marc´s calculator v0.0.1\n";

my $term = Term::ReadLine->new("Marc's calculator");

while(1) {
    my $input = $term->readline("mcalc> ");

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
      my $result = evaluate(\$tree);

      printf "%.3f\n", $result;
    };
    if(my $error = $@) {
      print $error;
    }
}
