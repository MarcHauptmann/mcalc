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

    is(evaluate(\$tree), 2, "Ergebnis ist 2");
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

    is(evaluate(\$tree), 6, "Ergebnis ist 6");
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

    is(evaluate(\$tree), 8, "Ergebnis ist 8");
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

    is(evaluate(\$tree), -2, "Ergebnis ist -2");
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

    is(evaluate(\$tree), .5, "Ergebnis ist 0.5");
};

print <<"EOF";
# ----------------------------------------
# Testet die Auswertung einer Potenz
# Eingabe:
#      ^
#     / \\
#    2   4
EOF

subtest "Potenz" => sub {
    my $tree = Tree->new("^");
    $tree->add_child(Tree->new("2"));
    $tree->add_child(Tree->new("4"));

    is(evaluate(\$tree), 16, "Ergebnis ist 16");
};

print <<"EOF";
# ----------------------------------------
# Testet die Auswertung eines mehrstufigen Baums
# Eingabe:
#      +
#     / \\
#    11  *
#       / \\
#      2   4
#
EOF

subtest "Operatorrangfolge" => sub {
  my $mul = Tree->new("*");
  $mul->add_child(Tree->new("2"));
  $mul->add_child(Tree->new("4"));

  my $tree = Tree->new("+");
  $tree->add_child($mul);
  $tree->add_child(Tree->new("11"));

  is(evaluate(\$tree), 19, "Ergebnis ist 19");
};


done_testing();
