#!/usr/bin/perl

use Test::More;
use evaluator;

print <<"EOF";
# ----------------------------------------
# Testet die Auswertung einer Zahl
# Eingabe: 2
EOF

subtest "Zahl" => sub {
    my $tree = Tree->new("2");

    is(evaluate($tree), 2, "Ergebnis ist 2");
};

print <<"EOF";
# ----------------------------------------
# Testet die Auswertung einer Addition
# Eingabe:
#      +
#     / \\
#    2   4
EOF

subtest "Addition" => sub {
    my $tree = Tree->new("+");
    $tree->add_child(Tree->new("2"));
    $tree->add_child(Tree->new("4"));

    is(evaluate($tree), 6, "Ergebnis ist 6");
};

print <<"EOF";
# ----------------------------------------
# Testet die Auswertung einer Multiplikation
# Eingabe:
#      *
#     / \\
#    2   4
EOF

subtest "Multiplikation" => sub {
    my $tree = Tree->new("*");
    $tree->add_child(Tree->new("2"));
    $tree->add_child(Tree->new("4"));

    is(evaluate($tree), 8, "Ergebnis ist 8");
};

print <<"EOF";
# ----------------------------------------
# Testet die Auswertung einer Subtraktion
# Eingabe:
#      -
#     / \\
#    2   4
EOF

subtest "Subtraktion" => sub {
    my $tree = Tree->new("-");
    $tree->add_child(Tree->new("2"));
    $tree->add_child(Tree->new("4"));

    is(evaluate($tree), -2, "Ergebnis ist -2");
};

print <<"EOF";
# ----------------------------------------
# Testet die Auswertung einer Division
# Eingabe:
#      /
#     / \\
#    2   4
EOF

subtest "Division" => sub {
    my $tree = Tree->new("/");
    $tree->add_child(Tree->new("2"));
    $tree->add_child(Tree->new("4"));

    is(evaluate($tree), .5, "Ergebnis ist 0.5");
};


done_testing();
