#!/usr/bin/perl

use parser;
use Test::More;

sub getTokens {
    my $tree = parse(@_[0]);

    my @preorder = map { $_->value() } $tree->traverse($tree->PRE_ORDER);

    print "# Rückgabe: ";
    foreach (@preorder) { 
	print $_." "; 
    } print "\n";

    return @preorder;
}

print <<"EOF";
# ----------------------------------------
# Teste parsen einer Zahl
EOF
    
subtest "eine Zahl" => sub {
    my @tokens = getTokens("1");

    is_deeply(\@tokens, [1], "Ergebnis stimmt");
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
    my @tokens = getTokens("1+2");

    is_deeply(\@tokens, ["+", 1, 2], "Ergebnis stimmt");
};

print <<"EOF";
# ----------------------------------------
# Teste Parsen einer Addition von drei Zahlen
# Eingabe: 1+2+3
# erwarteter Baum:
#        +    
#       / \\
#      1   +
#         / \\
#         2   3
#
# preorder: + 1 + 2 3
EOF

subtest "3-er Addition" => sub {
    my @tokens = getTokens("1+2+3");

    is_deeply(\@tokens, ["+", 1, "+", 2, 3], "Ergebnis stimmt");
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
    my @tokens = getTokens("2*3+4");

    is_deeply(\@tokens, ["+", "*", 2, 3, 4], "Ergebnis stimmt");
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
# preorder: + 2 * 3 4
EOF

subtest "Operatorrangfolge" => sub {
    my @tokens = getTokens("2+3*4");

    is_deeply(\@tokens, ["+", 2, "*", 3, 4]);
};

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

subtest "Addition zweier Multiplikationen" => sub {
  my @tokens = getTokens("2*3+4*5");

  is_deeply(\@tokens, ["+", "*", 2, 3, "*", 4, 5], "Ergebnis stimmt");
};

print<<"EOF";
# ----------------------------------------
# Teste großen Ausdruck
# Eingabe: 2*3+4*5+6
# erwarteter Baum:
#              +
#             / \\
#            /   \\
#           *     +
#          / \\   / \\
#         2   3 *   6
#              / \\
#             4   5
#
# preorder: + * 2 3 + * 4 5 6
EOF

subtest "großer Ausdruck" => sub {
    my @tokens = getTokens("2*3+4*5+6");

    is_deeply(\@tokens, ["+", "*", 2, 3, "+", "*", 4, 5, 6], "Ergebnis stimmt");
};

print <<"EOF";
# ----------------------------------------
# Teste Klammerung
# Eingabe: 2*(3+4)
# erwarteter Baum:
#          *
#         / \\
#        2   +
#           / \\
#          4   3
#
# preorder: * 2 + 3 4
EOF

subtest "Operatorrangfolge" => sub {
  my @tokens = getTokens("2*(3+4)");

  is_deeply(\@tokens, ["*", 2, "+", 3, 4], "Ergebnis stimmt");
};


print <<"EOF";
# ----------------------------------------
# Teste Klammerung anders herum
# Eingabe: (3+4)*2
# erwarteter Baum:
#          *
#         / \\
#        +   2
#       / \\
#      3   4
#
# preorder: * + 3 4 2
EOF

subtest "Operatorrangfolge" => sub {
    my @tokens = getTokens("(3+4)*2");

    is_deeply(\@tokens, ["*", "+", 3, 4, 2], "Ergebnis passt");
};

print <<"EOF";
# ----------------------------------------
# Teste Funktionen
# Eingabe: sum(2, 5, 7)
# erwarteter Baum:
#             +
#            / \\
#           /   \\
#         sum   cos
#         /|\\   / \\
#        2 5 7 1   2
EOF

subtest "Funktionen" => sub {
  my $tree = parse("sum(2,5,7)+cos(1,2)");

  is($tree->size(), 8, "Größe ist 8");
  is($tree->value(), "+", "Operation ist +");
  is($tree->children(0)->value(), "sum", "erster Zweig ist sum");
  is($tree->children(0)->size(), 4, "sum-Tree hat Größe 4");

  my @sum_elements = map { $_->value() } $tree->children(0)->children();
  is_deeply(\@sum_elements, [2, 5, 7], "Elemente stimmen");

  is($tree->children(1)->value(), "cos", "zweiter Zweig ist cos");
  is($tree->children(1)->size(), 3, "cos-Tree hat Größe 3");

  my @cos_elements = map { $_->value() } $tree->children(1)->children();
  is_deeply(\@cos_elements, [1, 2], "Elemente stimmen");
};

done_testing();
