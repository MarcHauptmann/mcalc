#!/usr/bin/perl

use Test::More;
use Test::Exception;
use MCalc::Evaluator;
use MCalc::Context;

subtest "sum function calculates sum" => sub {
  my $context = MCalc::Context->new();

  my $tree = Tree->new("sum");
  $tree->add_child(Tree->new("i"));
  $tree->add_child(Tree->new("i"));
  $tree->add_child(Tree->new("1"));
  $tree->add_child(Tree->new("4"));

  my $result = evaluateTree(\$context, \$tree);

  is($result, 10, "result is 10");
};

subtest "sum function does not redefine variable" => sub {
  my $context = MCalc::Context->new();

  $context->setVariable("i", 100);

  my $tree = Tree->new("sum");
  $tree->add_child(Tree->new("i"));
  $tree->add_child(Tree->new("i"));
  $tree->add_child(Tree->new("1"));
  $tree->add_child(Tree->new("4"));

  my $result = evaluateTree(\$context, \$tree);

  is($context->getVariable("i"), 100, "varable i may not change");
};

done_testing();
