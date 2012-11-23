#!/usr/bin/perl

use Test::More;
use MCalc::Util::TreeBuilder;
use MCalc::SimpleContext;

BEGIN {
  use_ok("MCalc::Functions::Simplification");
}

subtest "variable is not simplified" => sub {
  my $simplification = MCalc::Functions::Simplification->new();

  my $result = $simplification->simplify(tree("var"));

  is_deeply($result, tree("var"), "result is not modified");
};

subtest "multiplication with 1 is identity" => sub {
  my $simplification = MCalc::Functions::Simplification->new();

  my $expression = <<EOF;
       *
      / \\
     a   1
EOF

  my $result = $simplification->simplify(tree($expression));

  is_deeply($result, tree("a"), "result is a");
};

subtest "multiplication with 0 is 0" => sub {
  my $simplification = MCalc::Functions::Simplification->new();

  my $expression = <<EOF;
       *
      / \\
     a   0
EOF

  my $result = $simplification->simplify(tree($expression));

  is_deeply($result, tree("0"), "result is 0");
};

subtest "complex products with one 0-factor are 0" => sub {
  my $simplification = MCalc::Functions::Simplification->new();

  my $expression = <<EOF;
       *
      / \\
     a   *
     ^  / \\
       b   *
       ^  / \\
         0   *
         ^  / \\
           c   d
EOF

  my $result = $simplification->simplify(tree($expression));

  is_deeply($result, tree("0"), "result is 0");
};

subtest "addition of 0 is identity" => sub {
  my $simplification = MCalc::Functions::Simplification->new();

  my $expression = <<EOF;
       +
      / \\
     a   0
EOF

  my $result = $simplification->simplify(tree($expression));

  is_deeply($result, tree("a"), "result is a");
};

subtest "addition and multiplication can be simplified together" => sub {
  my $simplification = MCalc::Functions::Simplification->new();

  my $expression = <<EOF;
       +
      / \\
     a   +
     ^  / \\
       *   c
      / \\
     d   0
EOF

  my $resultTree = <<EOF;
         +
        / \\
       a   c
EOF

  my $result = $simplification->simplify(tree($expression));

  is_deeply($result, tree($resultTree), "result is a + c");
};

done_testing();
