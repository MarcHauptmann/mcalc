#!/usr/bin/perl

use Test::More;
use Test::Exception;
use Evaluator;

print <<"EOF";
# ----------------------------------------
# Testet die Auswertung einer Zahl
# Eingabe: 2
EOF

subtest "Zahl" => sub {
  my $evaluator = Evaluator->new();
  my $tree = Tree->new("2");

  is($evaluator->evaluate(\$tree), 2, "Ergebnis ist 2");
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

  my $evaluator = Evaluator->new();

  is($evaluator->evaluate(\$tree), 6, "Ergebnis ist 6");
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

  my $evaluator = Evaluator->new();

  is($evaluator->evaluate(\$tree), 8, "Ergebnis ist 8");
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

  my $evaluator = Evaluator->new();

  is($evaluator->evaluate(\$tree), -2, "Ergebnis ist -2");
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

  my $evaluator = Evaluator->new();

  is($evaluator->evaluate(\$tree), .5, "Ergebnis ist 0.5");
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

  my $evaluator = Evaluator->new();

  is($evaluator->evaluate(\$tree), 16, "Ergebnis ist 16");
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

  my $evaluator = Evaluator->new();

  is($evaluator->evaluate(\$tree), 19, "Ergebnis ist 19");
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
  my $cos = Tree->new("cos");
  $cos->add_child(Tree->new("0"));

  my $evaluator = Evaluator->new();

  is($evaluator->evaluate(\$cos), 1, "Ergebnis ist 1");
};

print <<"EOF";
# ----------------------------------------
# Testet Auswertung von Variable
# Eingabe: pi
EOF

subtest "Auswertung" => sub {
  my $evaluator = Evaluator->new();
  my $val = Tree->new("pi");

  $expected = $evaluator->getVariable("pi");


  is($evaluator->evaluate(\$val), $expected, "pi geht");
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

  my $evaluator = Evaluator->new();

  $evaluator->evaluate(\$stmt);

  isnt($evaluator->getVariable("var"), undef, "var ist definiert");
  is($evaluator->getVariable("var"), 1, "var ist 1");
};

print <<"EOF";
# ----------------------------------------
# test completion
EOF

subtest "completion pi" => sub{
  my $evaluator = Evaluator->new();

  my @completions = $evaluator->getCompletions("p");

  is(scalar(@completions), 1, "one completion");
  is_deeply(\@completions, ["pi"], "pi wird komplettiert");
};

print <<"EOF";
# ----------------------------------------
# test completion
EOF

subtest "completion cos" => sub{
  my $evaluator = Evaluator->new();

  my @completions = $evaluator->getCompletions("co");

  is(scalar(@completions), 2, "one completion");
  is_deeply(\@completions, ["cos", "cot"], "'cos' and 'cot' works");
};

print <<"EOF";
# ----------------------------------------
# test sum function
EOF

subtest "sum function calculates sum" => sub {
  my $evaluator = Evaluator->new();

  my $tree = Tree->new("sum");
  $tree->add_child(Tree->new("i"));
  $tree->add_child(Tree->new("i"));
  $tree->add_child(Tree->new("1"));
  $tree->add_child(Tree->new("4"));

  my $result = $evaluator->evaluate(\$tree);

  is($result, 10, "result is 10");
};

subtest "sum function does not redefine variable" => sub {
  my $evaluator = Evaluator->new();

  $evaluator->setVariable("i", 100);

  my $tree = Tree->new("sum");
  $tree->add_child(Tree->new("i"));
  $tree->add_child(Tree->new("i"));
  $tree->add_child(Tree->new("1"));
  $tree->add_child(Tree->new("4"));

  is($evaluator->getVariable("i"), 100, "varable i may not change");
};

subtest "dies on unknown variable" => sub {
  my $evaluator = Evaluator->new();

  dies_ok { $evaluator->getVariable("unknownVar"); };
};

subtest "dies on unknown function" => sub {
  my $evaluator = Evaluator->new();

  dies_ok { $evaluator->getFunction("unknownFunction"); };
};

done_testing();
