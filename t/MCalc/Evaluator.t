#!/usr/bin/perl

use Test::More;
use Test::Exception;
use MCalc::DefaultContext;

BEGIN {
  use_ok("MCalc::Evaluator");
}

print <<"EOF";
# ----------------------------------------
# Testet die Auswertung einer Zahl
# Eingabe: 2
EOF

subtest "Zahl" => sub {
  my $context = MCalc::DefaultContext->new();
  my $tree = Tree->new("2");

  is(evaluateTree(\$context, \$tree), 2, "Ergebnis ist 2");
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
  my $context = MCalc::DefaultContext->new();

  my $tree = Tree->new("+");
  $tree->add_child(Tree->new("2"));
  $tree->add_child(Tree->new("4"));

  my $result = evaluateTree(\$context, \$tree);

  is($result, 6, "Ergebnis ist 6");
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
  my $context = MCalc::DefaultContext->new();

  my $tree = Tree->new("*");
  $tree->add_child(Tree->new("2"));
  $tree->add_child(Tree->new("4"));

  is(evaluateTree(\$context, \$tree), 8, "Ergebnis ist 8");
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
  my $context = MCalc::DefaultContext->new();

  my $tree = Tree->new("-");
  $tree->add_child(Tree->new("2"));
  $tree->add_child(Tree->new("4"));

  is(evaluateTree(\$context, \$tree), -2, "Ergebnis ist -2");
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
  my $context = MCalc::DefaultContext->new();

  my $tree = Tree->new("/");
  $tree->add_child(Tree->new("2"));
  $tree->add_child(Tree->new("4"));

  is(evaluateTree(\$context, \$tree), .5, "Ergebnis ist 0.5");
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
  my $context = MCalc::DefaultContext->new();

  my $tree = Tree->new("^");
  $tree->add_child(Tree->new("2"));
  $tree->add_child(Tree->new("4"));

  is(evaluateTree(\$context, \$tree), 16, "Ergebnis ist 16");
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
  my $context = MCalc::DefaultContext->new();

  my $mul = Tree->new("*");
  $mul->add_child(Tree->new("2"));
  $mul->add_child(Tree->new("4"));

  my $tree = Tree->new("+");
  $tree->add_child($mul);
  $tree->add_child(Tree->new("11"));

  is(evaluateTree(\$context, \$tree), 19, "Ergebnis ist 19");
};

print <<"EOF";
# ----------------------------------------
# Testet die Auswertung des Cosinus
# Eingabe:
#     cos
#      |
#      0
EOF

subtest "Cosine" => sub {
  my $context = MCalc::DefaultContext->new();

  my $cos = Tree->new("cos");
  $cos->add_child(Tree->new("0"));

  is(evaluateTree(\$context, \$cos), 1, "Ergebnis ist 1");
};

print <<"EOF";
# ----------------------------------------
# Testet Auswertung von Variable
# Eingabe: pi
EOF

subtest "Auswertung" => sub {
  my $context = MCalc::DefaultContext->new();

  my $val = Tree->new("pi");

  $expected = $context->getVariable("pi");

  is(evaluateTree(\$context, \$val), $expected, "pi geht");
};

done_testing();
