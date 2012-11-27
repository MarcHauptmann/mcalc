#!/usr/bin/perl

use Test::More;
use MCalc::SimpleContext;
use MCalc::DefaultContext;
use MCalc::Util::TreeBuilder;

BEGIN {
  use_ok("MCalc::Functions::Integration");
}

subtest "int(x,x,0,1) can be calculated" => sub {
  my $context = MCalc::SimpleContext->new();
  my $integration = MCalc::Functions::Integration->new();

  my $result = $integration->evaluate($context, tree("x"), tree("x"),
                                      tree("0"), tree("1"));

  is($result, 0.5, "result is 0.5");
};

subtest "int(x,x,0,5) can be calculated" => sub {
  my $context = MCalc::SimpleContext->new();
  my $integration = MCalc::Functions::Integration->new();

  my $result = $integration->evaluate($context, tree("x"), tree("x"),
                                      tree("0"), tree("5"));

  is($result, 12.5, "result is 12.5");
};

subtest "int(sin(x),x,0,pi) can be calculated" => sub {
  my $context = MCalc::DefaultContext->new();
  my $integration = MCalc::Functions::Integration->new();

  my $expression = <<EOF;
       sin
        |
        x
EOF

  my $result = $integration->evaluate($context, tree($expression), tree("x"),
                                      tree("0"), tree("pi"));

  cmp_ok(abs($result-2), "<", 1e-8, "result is near 2");
};

subtest "int(x^3, x, -1, 1) must be nearly 0" => sub {
  my $context = MCalc::DefaultContext->new();
  my $integration = MCalc::Functions::Integration->new();

  my $expression = <<EOF;
        ^
       / \\
      x   3
EOF

  my $lowerBound = <<EOF;
    neg
     |
     1
EOF

  my $result = $integration->evaluate($context, tree($expression), tree("x"), tree($lowerBound), tree("1"));

  cmp_ok($result, "<", 1e-15, "result is nearly 0");
};

done_testing();
