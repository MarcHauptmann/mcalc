#!/usr/bin/perl

use parser;
use Test::More;

sub getTree {
    my $tree = parseTree(@_[0]);

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
#        1   2
#
# preorder: + 1 2
EOF

subtest "Addition" => sub {
    my $tree = getTree("1+2");
    my @tokens = $tree->traverse($tree->PRE_ORDER);

    is(scalar(@tokens), 3, "drei Elemente");
    is($tokens[0]->value(), "+", "Root ist +");
    is($tokens[1]->value(), "1", "erstes Kind ist 1");
    is($tokens[2]->value(), "2", "zweites Kind ist 2");
};

print <<"EOF";
# ----------------------------------------
# Teste Parsen einer Addition von drei Zahlen
# Eingabe: 1+2+3
# erwarteter Baum:
#        +    
#       / \\
#      +   3
#     / \\ 
#    1   2
#
# preorder: + + 1 2 3
EOF

subtest "3-er Addition" => sub {
    my $tree = getTree("1+2+3");
    my @tokens = $tree->traverse($tree->PRE_ORDER);

    is(scalar(@tokens), 5, "fünf Elemente");
    is($tokens[0]->value(), "+", "Root ist +");
    is($tokens[1]->value(), "+", "neuer Zweig +");
    is($tokens[2]->value(), "1", "erstes Kind ist 1");
    is($tokens[3]->value(), "2", "zweites Kind ist 2");
    is($tokens[4]->value(), "3", "zweites Kind ist 3");
};

print <<"EOF";
# ----------------------------------------
# Teste Beachtung der Operatorrangfolge
# Eingabe: 2*3+4
# erwarteter Baum:
#          +
#         / \\
#        *   4
#       / \\
#      2   3
#
# preorder: + * 2 3 4
EOF

subtest "Operatorrangfolge" => sub {
    my $tree = getTree("2*3+4");
    my @tokens = $tree->traverse($tree->PRE_ORDER);

    is(scalar(@tokens), 5, "fünf Elemente");
    is($tokens[0]->value(), "+", "Root ist +");
    is($tokens[1]->value(), "*", "neuer Zweig *");
    is($tokens[2]->value(), "2", "erstes Kind ist 2");
    is($tokens[3]->value(), "3", "zweites Kind ist 3");
    is($tokens[4]->value(), "4", "zweites Kind ist 4");
};

print <<"EOF";
# ----------------------------------------
# Teste Beachtung der Operatorrangfolge
# Eingabe: 2*3+4
# erwarteter Baum:
#          +
#         / \\
#        2   *
#           / \\
#          3   4
#
# preorder: + 2 * 3 4
EOF

subtest "Operatorrangfolge" => sub {
    my $tree = getTree("2+3*4");
    my @tokens = $tree->traverse($tree->PRE_ORDER);

    is(scalar(@tokens), 5, "fünf Elemente");
    is($tokens[0]->value(), "+", "Root ist +");
    is($tokens[1]->value(), "2", "erstes Kind ist 2");
    is($tokens[2]->value(), "*", "neuer Zweig *");
    is($tokens[3]->value(), "3", "erstes Kind ist 3");
    is($tokens[4]->value(), "4", "zweites Kind ist 4");
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
#      2   3 4   5
#
# preorder: + * 2 3 * 4 5
EOF

	my $tree = getTree("2*3+4*5");
    my @tokens = $tree->traverse($tree->PRE_ORDER);

    is(scalar(@tokens), 7, "7 Elemente");
    is($tokens[0]->value(), "+", "Root ist +");
    is($tokens[1]->value(), "*", "neuer Zweig *");
    is($tokens[2]->value(), "2", "erstes Kind ist 2");
    is($tokens[3]->value(), "3", "zweites Kind ist 3");
    is($tokens[4]->value(), "*", "neuer Zweig *");
    is($tokens[5]->value(), "4", "erstes Kind ist 4");
    is($tokens[6]->value(), "5", "zweites Kind ist 5");
};

print<<"EOF";
# ----------------------------------------
# Teste großen Ausdruck
# Eingabe: 2*3+4*5+6
# erwarteter Baum:
#             +
#            / \\
#           +   6
#          / \\
#         /   \\
#        *     *
#       / \\   / \\
#      2   3 4   5
#
# preorder: + + * 2 3 * 4 5 6
EOF

subtest "großer Ausdruck" => sub {    
    my $tree = getTree("2*3+4*5+6");
    my @tokens = $tree->traverse($tree->PRE_ORDER);
    
    is(scalar(@tokens), 9, "9 Elemente");
    is($tokens[0]->value(), "+", "Root ist +");
    is($tokens[1]->value(), "+", "neuer Zweig +");
    is($tokens[2]->value(), "*", "neuer Zweit *");
    is($tokens[3]->value(), "2", "erstes Kind ist 2");
    is($tokens[4]->value(), "3", "zweites Kind ist 3");
    is($tokens[5]->value(), "*", "neuer Zweig *");
    is($tokens[6]->value(), "4", "erstes Kind ist 4");
    is($tokens[7]->value(), "5", "zweites Kind ist 5");
    is($tokens[8]->value(), "6", "zweites Kind ist 6");
};


done_testing();
