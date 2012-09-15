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

print <<"EOF";
# ----------------------------------------
# Testet Auswertung von Variable
# Eingabe: pi
EOF

subtest "Auswertung" => sub {
  $val = Tree->new("pi");

  $expected = getVariable("pi");
  is(evaluate(\$val), $expected, "pi geht");
};

print <<"EOF";
# ----------------------------------------
# Testet eine Zuweisung
# Eingabe:
#      =
#     / \\
#   var  1
EOF

subtest "Zuweisung" => sub {
  my $stmt = Tree->new("=");
  $stmt->add_child(Tree->new("var"));
  $stmt->add_child(Tree->new("1"));

  evaluate(\$stmt);

  isnt(getVariable("var"), undef, "var ist definiert");
  is(getVariable("var"), 1, "var ist 1");
};

print <<"EOF";
# ----------------------------------------
# test completion
EOF

subtest "completion pi" => sub{
  my @completions = getCompletions("p");

  is(scalar(@completions), 1, "one completion");
  is_deeply(\@completions, ["pi"], "pi wird komplettiert");
};

print <<"EOF";
# ----------------------------------------
# test completion
EOF

subtest "completion cos" => sub{
  my @completions = getCompletions("co");

  is(scalar(@completions), 2, "one completion");
  is_deeply(\@completions, ["cos", "cot"], "'cos' and 'cot' works");
};

done_testing();
