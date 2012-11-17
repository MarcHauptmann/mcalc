#!/usr/bin/perl

use Test::More;

use Evaluator;
use MCalc::Context;
use Tree;

BEGIN {
  use_ok("MCalc::Functions::Product");
}

subtest "product can be calculated" => sub {
  my $context = MCalc::Context->new();
  my $evaluator = Evaluator->new();

  $context->setFunction("prod", MCalc::Functions::Product->new());

  my $tree = Tree->new("prod");
  $tree->add_child(Tree->new("n"));
  $tree->add_child(Tree->new("n"));
  $tree->add_child(Tree->new("1"));
  $tree->add_child(Tree->new("3"));

  my $result = $evaluator->evaluate(\$context, \$tree);

  is($result, 6, "result is 6");
};

subtest "parameters are evaluated" => sub {
  my $context = MCalc::Context->new();
  my $evaluator = Evaluator->new();

  $context->setFunction("prod", MCalc::Functions::Product->new());
  $context->setVariable("n", 100);

  my $fromTree = Tree->new("+");
  $fromTree->add_child(Tree->new("1"));
  $fromTree->add_child(Tree->new("2"));

  my $toTree = Tree->new("+");
  $toTree->add_child(Tree->new("2"));
  $toTree->add_child(Tree->new("3"));

  my $tree = Tree->new("prod");
  $tree->add_child(Tree->new("n"));
  $tree->add_child(Tree->new("n"));
  $tree->add_child($fromTree);
  $tree->add_child($toTree);

  my $result = $evaluator->evaluate(\$context, \$tree);

  is($result, 60, "'from' and 'to' are evaluated");
};

subtest "variables are not redefined" => sub {
  my $context = MCalc::Context->new();
  my $evaluator = Evaluator->new();

  $context->setFunction("prod", MCalc::Functions::Product->new());
  $context->setVariable("n", 100);

  my $tree = Tree->new("prod");
  $tree->add_child(Tree->new("n"));
  $tree->add_child(Tree->new("n"));
  $tree->add_child(Tree->new("1"));
  $tree->add_child(Tree->new("3"));

  $evaluator->evaluate(\$context, \$tree);

  is($context->getVariable("n"), 100, "variable didn't change");
};

done_testing();
