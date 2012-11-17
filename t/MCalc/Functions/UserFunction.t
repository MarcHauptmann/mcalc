#!/usr/bin/perl

use Test::More;
use Evaluator;
use MCalc::Context;
use Tree;

BEGIN {
  use_ok("MCalc::Functions::UserFunction");
}

subtest "function can be evaluated" => sub {
  my $context = MCalc::Context->new();
  my $evaluator = Evaluator->new();

  my $func = MCalc::Functions::UserFunction->new(arguments => ["x"],
                                                 body => Tree->new("x"));

  my $arg = Tree->new(2);

  my $result = $func->evaluate(\$evaluator, \$context, \$arg);

  is($result, 2, "result is 2");
};

subtest "variables are not redefined" => sub {
  my $context = MCalc::Context->new();
  my $evaluator = Evaluator->new();

  my $func = MCalc::Functions::UserFunction->new(arguments => ["x"],
                                                 body => Tree->new("x"));

  my $arg = Tree->new(2);

  $context->setVariable("x", 5);

  my $result = $func->evaluate(\$evaluator, \$context, \$arg);

  is($context->getVariable("x"), 5, "x is not redefined");
};

done_testing();
