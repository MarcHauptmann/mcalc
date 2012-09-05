#!/usr/bin/perl

use parser;
use Test::More;

sub getTree {
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
    my @tokens = getTree("1");

    is_deeply(\@tokens, [1], "Ergebnis stimmt");
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
    my @tokens = getTree("1+2");

    is_deeply(\@tokens, ["+", 2, 1], "Ergebnis stimmt");
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
    my @tokens = getTree("1+2+3");

    is_deeply(\@tokens, ["+", "+", 3, 2, 1], "Ergebnis stimmt");
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
    my @tokens = getTree("2*3+4");

    is_deeply(\@tokens, ["+", 4, "*", 3, 2], "Ergebnis stimmt");
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
    my @tokens = getTree("2+3*4");

    is_deeply(\@tokens, ["+", "*", 4, 3, 2]);
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
#      5   4 3   2
#
# preorder: + * 5 4 * 3 2
EOF

subtest "Addition zweier Multiplikationen" => sub {
  my @tokens = getTree("2*3+4*5");

  is_deeply(\@tokens, ["+", "*", 5, 4, "*", 3, 2], "Ergebnis stimmt");
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
    my @tokens = getTree("2*3+4*5+6");

    is_deeply(\@tokens, ["+", "+", 6, "*", 5, 4, "*", 3, 2], "Ergebnis stimmt");
};

print <<"EOF";
# ----------------------------------------
# Teste Klammerung
# Eingabe: 2*(3+4)
# erwarteter Baum:
#          *
#         / \\
#        +   2
#       / \\
#      4   3
#
# preorder: * + 4 3 2
EOF

subtest "Operatorrangfolge" => sub {
  my @tokens = getTree("2*(3+4)");

  is_deeply(\@tokens, ["*", "+", 4, 3, 2], "Ergebnis stimmt");
};


print <<"EOF";
# ----------------------------------------
# Teste Klammerung anders herum
# Eingabe: (3+4)*2
# erwarteter Baum:
#          *
#         / \\
#        2   +
#           / \\
#          4   3
#
# preorder: * 2 + 4 3
EOF

subtest "Operatorrangfolge" => sub {
    my @tokens = getTree("(3+4)*2");

    is_deeply(\@tokens, ["*", "2", "+", "4", "3"], "Ergebnis passt");
};

done_testing();
