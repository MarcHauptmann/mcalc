#!/usr/bin/perl

use Test::More;
use MCalc::SimpleContext;
use MCalc::Util::TreeBuilder;

BEGIN {
  use_ok("MCalc::Functions::Multiplication");
}

subtest "multiplication of numbers works" => sub {
  my $context = MCalc::SimpleContext->new();
  my $add = MCalc::Functions::Multiplication->new();

  is_deeply($add->evaluate($context, tree("2"), tree("3")), tree("6"));
};


subtest "multiplication of unknown variable returns tree" => sub {
  my $context = MCalc::SimpleContext->new();
  my $add = MCalc::Functions::Multiplication->new();

  my $expected = <<'EOF';
     *
    / \
   x   2
EOF

  is_deeply($add->evaluate($context, tree("x"), tree("2")), tree($expected));
};

done_testing();
