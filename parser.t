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
#        1   2
#
# preorder: + 1 2
EOF

subtest "Addition" => sub {
    my @tokens = getTree("1+2");

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
    my @tokens = getTree("1+2+3");

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
    my @tokens = getTree("2*3+4");

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
    my @tokens = getTree("2+3*4");

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
  my @tokens = getTree("2*3+4*5");

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
    my @tokens = getTree("2*3+4*5+6");

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
  my @tokens = getTree("2*(3+4)");

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
    my @tokens = getTree("(3+4)*2");

    is_deeply(\@tokens, ["*", "+", 3, 4, 2], "Ergebnis passt");
};

done_testing();
