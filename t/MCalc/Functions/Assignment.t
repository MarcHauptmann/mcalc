#!/usr/bin/perl

use Test::More;
use Evaluator;
use MCalc::Context;
use MCalc::Functions::UserFunction;

BEGIN {
  use_ok("MCalc::Functions::Assignment");
}

subtest "variable can be assigned" => sub {
  my $context = MCalc::Context->new();
  my $evaluator = Evaluator->new();

  my $stmt = Tree->new("=");
  $stmt->add_child(Tree->new("var"));
  $stmt->add_child(Tree->new("1"));

  $evaluator->evaluate(\$context, \$stmt);

  isnt($context->getVariable("var"), undef, "var ist definiert");
  is($context->getVariable("var"), 1, "var ist 1");
};

subtest "function can be assigned" => sub {
  my $context = MCalc::Context->new();
  my $evaluator = Evaluator->new();

  my $funcTree = Tree->new("f");
  $funcTree->add_child(Tree->new("x"));
  $funcTree->add_child(Tree->new("y"));

  my $bodyTree = Tree->new("+");
  $bodyTree->add_child(Tree->new("x"));
  $bodyTree->add_child(Tree->new("y"));

  my $stmt = Tree->new("=");
  $stmt->add_child($funcTree);
  $stmt->add_child($bodyTree);

  $evaluator->evaluate(\$context, \$stmt);

  my $expected = MCalc::Functions::UserFunction->new(arguments => ["x", "y"],
						     body => $bodyTree);

  ok($context->functionIsDefined("f"));
  is_deeply($context->getFunction("f"), $expected, "function matches");
};

done_testing();
