#!/usr/bin/perl

use Test::More;
use MCalc::Util::TreeBuilder;
use MCalc::DefaultContext;
use MCalc::SimplePrinter;

our $printer = MCalc::SimplePrinter->new();
our $parser = MCalc::Parser->new();

BEGIN {
  use_ok("MCalc::Functions::Simplify");
}	
	
subtest "variable is not simplified" => sub {
  my $context = MCalc::DefaultContext->new();
  my $simplify = MCalc::Functions::Simplify->new();

  my $result = $simplify->evaluate($context, tree("var"));

  is_deeply($result, tree("var"), "result is not modified");
};

subtest "multiplication with 1 is identity" => sub {
  my $context = MCalc::DefaultContext->new();
  my $simplify = MCalc::Functions::Simplify->new();

  my $expression = <<'EOF';
       *
      / \
     a   1
EOF

  my $result = $simplify->evaluate($context, tree($expression));

  is_deeply($result, tree("a"), "result is a");
};


subtest "multiplication with 0 is 0" => sub {
  my $context = MCalc::DefaultContext->new();
  my $simplify = MCalc::Functions::Simplify->new();

  my $expression1 = $parser->parse("a*0");
  my $expression2 = $parser->parse("0*a");

  my $result1 = $simplify->evaluate($context, $expression1);
  my $result2 = $simplify->evaluate($context, $expression2);

  is_deeply($result1, tree("0"), "result is 0");
  is_deeply($result2, tree("0"), "result is 0");
};

subtest "complex products with one 0-factor are 0" => sub {
  my $context = MCalc::DefaultContext->new();
  my $simplify = MCalc::Functions::Simplify->new();

  my $expression = <<'EOF';
           *
          / \
         c   *
         ^  / \
           d   0
EOF

  my $result = $simplify->evaluate($context, tree($expression));

  is_deeply($result, tree("0"), "result is 0");
};

subtest "addition of 0 is identity" => sub {
  my $context = MCalc::DefaultContext->new();
  my $simplify = MCalc::Functions::Simplify->new();

  my $expression1 = <<EOF;
       +
      / \\
     a   0
EOF

  my $expression2 = <<EOF;
       +
      / \\
     a   0
EOF

  my $result1 = $simplify->evaluate($context, tree($expression1));
  my $result2 = $simplify->evaluate($context, tree($expression2));

  is_deeply($result1, tree("a"), "result is a");
  is_deeply($result2, tree("a"), "result is a");
};

subtest "addition and multiplication can be simplified together" => sub {
  my $context = MCalc::DefaultContext->new();
  my $simplify = MCalc::Functions::Simplify->new();

  my $expression = <<'EOF';
       +
      / \
     a   +
     ^  / \
       *   c
      / \
     d   0
EOF

  my $resultTree = <<'EOF';
         +
        / \
       a   c
EOF

  my $result = $simplify->evaluate($context, tree($expression));

  printf "result = %s\n", $printer->to_string($result);

  is_deeply($result, tree($resultTree), "result is a + c");
};

subtest "calculations can be performed during simplification" => sub {
  my $context = MCalc::DefaultContext->new();
  my $simplify = MCalc::Functions::Simplify->new();

  my $expression = <<'EOF';
            *
          /   \
        /       \
       +         /
      / \       / \
     a   -     4   4
     ^  / \
       1   1
EOF

  my $result = $simplify->evaluate($context, tree($expression));

  is_deeply($result, tree("a"), "result is a");
};

subtest "calculations can be performed during simplification" => sub {
  my $context = MCalc::DefaultContext->new();
  my $simplify = MCalc::Functions::Simplify->new();

  my $expression = <<'EOF';
            *
           / \
          *   x
         / \
        3   5
EOF

  my $expected = <<'EOF';
     *
    / \
   x   15
EOF

  my $result = $simplify->evaluate($context, tree($expression));

  printf "result = %s\n", $printer->to_string($result);

  is_deeply($result, tree($expected), "result is a");
};

subtest "calculations use defined variables" => sub {
  my $simplify = MCalc::Functions::Simplify->new();
  my $context = MCalc::DefaultContext->new();
  $context->setVariable("x", 2);

  my $expression = <<'EOF';
        *
       / \
      /   \
     a     /
     ^    / \
         2   x
EOF

  my $result = $simplify->evaluate($context, tree($expression));

  is_deeply($result, tree("a"), "result is a");
};

subtest "calculations use defined variables" => sub {
  my $simplification = MCalc::Functions::Simplify->new();
  my $context = MCalc::DefaultContext->new();

  my $expression = $parser->parse("(2*a)*(1/2)");

  my $result = $simplification->evaluate($context, $expression);
  my $expected = $parser->parse("a");

  printf "result = %s\n", $printer->to_string($result);

  is_deeply($result, $expected, "result is a");
};

done_testing();
