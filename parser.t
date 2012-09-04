#!/usr/bin/perl

use parser;
use Test::More;

sub getTree {
    my $tree = parse(@_[0]);

    print "# Rückgabe: ";
    foreach ($tree->traverse($tree->PRE_ORDER)) { 
	print $_->value()." "; 
    } print "\n";

    return $tree;
}

print <<"EOF";
# ----------------------------------------
# Teste parsen einer Zahl
EOF
    
subtest "eine Zahl" => sub {
    my $tree = getTree("1");

    is($tree->size(), 1, "nur ein Element");
    is($tree->value(), "1", "Element ist 1");
};

print <<"EOF";
# ----------------------------------------
# Teste Parsen einer Addition
# erwarteter Baum:
#          +
#         / \\
#        2   1
#
# preorder: + 2 1
EOF

subtest "Addition" => sub {
    my $tree = getTree("1+2");
    my @tokens = $tree->traverse($tree->PRE_ORDER);

    is(scalar(@tokens), 3, "drei Elemente");
    is($tokens[0]->value(), "+", "Root ist +");
    is($tokens[1]->value(), 2, "erstes Kind ist 2");
    is($tokens[2]->value(), 1, "zweites Kind ist 1");
};

print <<"EOF";
# ----------------------------------------
# Teste Parsen einer Addition von drei Zahlen
# Eingabe: 1+2+3
# erwarteter Baum:
#        +    
#       / \\
#      +   1
#     / \\
#    3   2
#
# preorder: + + 3 2 1
EOF

subtest "3-er Addition" => sub {
    my $tree = getTree("1+2+3");
    my @tokens = $tree->traverse($tree->PRE_ORDER);

    is(scalar(@tokens), 5, "fünf Elemente");
    is($tokens[0]->value(), "+", "Root ist +");
    is($tokens[1]->value(), "+", "neuer Zweig +");
    is($tokens[2]->value(), "3", "erstes Kind ist 3");
    is($tokens[3]->value(), "2", "zweites Kind ist 2");
    is($tokens[4]->value(), "1", "zweites Kind ist 1");
};

print <<"EOF";
# ----------------------------------------
# Teste Beachtung der Operatorrangfolge
# Eingabe: 2*3+4
# erwarteter Baum:
#          +
#         / \\
#        4   *
#           / \\
#          3   2
#
# preorder: + 4 * 3 2
EOF

subtest "Operatorrangfolge" => sub {
    my $tree = getTree("2*3+4");
    my @tokens = $tree->traverse($tree->PRE_ORDER);

    is(scalar(@tokens), 5, "fünf Elemente");
    is($tokens[0]->value(), "+", "+ erwartet");
    is($tokens[1]->value(), "4", "4 erwartet");
    is($tokens[2]->value(), "*", "* erwartet");
    is($tokens[3]->value(), "3", "3 erwartet");
    is($tokens[4]->value(), "2", "2 erwartet");
};

print <<"EOF";
# ----------------------------------------
# Teste Beachtung der Operatorrangfolge
# Eingabe: 2+3*4
# erwarteter Baum:
#          +
#         / \\
#        2   *
#           / \\
#          3   4
#
# preorder: + * 4 3 2
EOF

subtest "Operatorrangfolge" => sub {
    my $tree = getTree("2+3*4");
    my @tokens = $tree->traverse($tree->PRE_ORDER);

    is(scalar(@tokens), 5, "fünf Elemente");
    is($tokens[0]->value(), "+", "+ erwartet");
    is($tokens[1]->value(), "*", "* erwartet");
    is($tokens[2]->value(), "4", "4 erwartet");
    is($tokens[3]->value(), "3", "3 erwartet");
    is($tokens[4]->value(), "2", "2 erwartet");
};

subtest "" => sub {
    print <<"EOF";
# ----------------------------------------
# Teste Addition von zwei Multiplikationen
# Eingabe: 2*3+4*5
# erwarteter Baum:
#           +
#          / \\
#         /   \\
#        *     *
#       / \\   / \\
#      5   4 3   2
#
# preorder: + * 5 4 * 3 2
EOF

	my $tree = getTree("2*3+4*5");
    my @tokens = $tree->traverse($tree->PRE_ORDER);

    is(scalar(@tokens), 7, "7 Elemente");
    is($tokens[0]->value(), "+", "+ erwartet");
    is($tokens[1]->value(), "*", "* erwartet");
    is($tokens[2]->value(), "5", "5 erwartet");
    is($tokens[3]->value(), "4", "4 erwartet");
    is($tokens[4]->value(), "*", "* erwartet");
    is($tokens[5]->value(), "3", "3 erwartet");
    is($tokens[6]->value(), "2", "2 erwartet");
};

print<<"EOF";
# ----------------------------------------
# Teste großen Ausdruck
# Eingabe: 2*3+4*5+6
# erwarteter Baum:
#               +
#             /   \\
#           +       *
#          / \\     / \\
#         6   *   3   2
#            / \\
#           5   4 
#
# preorder: + + 6 * 5 4 * 3 2
EOF

subtest "großer Ausdruck" => sub {    
    my $tree = getTree("2*3+4*5+6");
    my @tokens = $tree->traverse($tree->PRE_ORDER);
    
    is(scalar(@tokens), 9, "9 Elemente");
    is($tokens[0]->value(), "+", "+ erwartet");
    is($tokens[1]->value(), "+", "+ erwartet");
    is($tokens[2]->value(), "6", "6 erwartet");
    is($tokens[3]->value(), "*", "* erwartet");
    is($tokens[4]->value(), "5", "5 erwartet");
    is($tokens[5]->value(), "4", "4 erwartet");
    is($tokens[6]->value(), "*", "* erwartet");
    is($tokens[7]->value(), "3", "3 erwartet");
    is($tokens[8]->value(), "2", "2 erwartet");
};

subtest "recursive descent parser" => sub {
  my $tree;
  my @list = (1, 2, 3);
  is(top(@list), 3, "3 bekommen");

  eval {$tree = parse("10");};
  is($@, "", "kein Fehler");
  isnt($tree, undef, "Tree ist definiert");
  is($tree->size(), 1, "Größe ist 1");
  is($tree->value(), 10, "Element ist 10");

  eval {$tree = parse("10+20"); };
  is($@, "", "kein Fehler");
  isnt($tree, undef, "Tree ist definiert");
  is($tree->size(), 3, "3 Elemente");

  my @list = $tree->traverse($tree->PRE_ORDER);
  is($list[0]->value(), "+", "+ ist Wurzel");
  is($list[1]->value(), "20", "20 erwartet");
  is($list[2]->value(), "10", "10 erwartet");

  eval {parse("a+a");};
  isnt($@, "", $@);

  eval {parse("10+a");};
  isnt($@, "", $@);

  eval { $tree = parse("1*(3+5)"); };
  is($@, "", "kein Fehler");
  isnt($tree, undef, "Tree ist definiert");
  is($tree->size(), 5, "Größe ist 5");

  my @list = $tree->traverse($tree->PRE_ORDER);
  is($list[0]->value(), "*", "Wurzel ist *");
  is($list[1]->value(), "+", "+ erwartet");
  is($list[2]->value(), "5", "5 erwartet");
  is($list[3]->value(), "3", "3 erwartet");
  is($list[4]->value(), "1", "1 erwartet");
};


done_testing();
