#!/usr/bin/perl

use Test::More;
use MCalc::Util::TreeBuilder;
use MCalc::SimpleContext;

BEGIN {
  use_ok("MCalc::Functions::Addition");
}

subtest "addition of numbers works" => sub {
  my $context = MCalc::SimpleContext->new();
  my $add = MCalc::Functions::Addition->new();

  is_deeply($add->evaluate($context, tree("1"), tree("2")), tree("3"));
};

subtest "addition of unknown variable returns tree" => sub {
  my $context = MCalc::SimpleContext->new();
  my $add = MCalc::Functions::Addition->new();

  my $expected = <<'EOF';
     +
    / \
   x   2
EOF

  is_deeply($add->evaluate($context, tree("x"), tree("2")), tree($expected));
};

done_testing();
