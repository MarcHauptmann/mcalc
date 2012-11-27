#!/usr/bin/perl

use Test::More;
use Test::Exception;
use MCalc::Evaluator;
use MCalc::DefaultContext;
use MCalc::Util::TreeBuilder;

subtest "sum function calculates sum" => sub {
  my $context = MCalc::DefaultContext->new();

  my $tree = <<EOF;
          sum
        / | | \\
       i  i 1  4
EOF

  my $result = evaluateTree($context, tree($tree));

  is($result, 10, "result is 10");
};

subtest "sum function does not redefine variable" => sub {
  my $context = MCalc::DefaultContext->new();
  $context->setVariable("i", 100);

  my $tree = <<EOF;
       sum
     / | | \\
    i  i 1  4
EOF

  my $result = evaluateTree($context, tree($tree));

  is($context->getVariable("i"), 100, "varable i may not change");
};

subtest "dies at too few parameters" => sub {
  my $context = MCalc::DefaultContext->new();
  my $sumFunction = MCalc::Functions::Sum->new();

  my $arg1 = Tree->new("i");
  my $arg2 = Tree->new("i");

  throws_ok { $sumFunction->evaluate($context, $arg1, $arg2) } "Error::Simple";
};

subtest "dies at too few parameters" => sub {
  my $context = MCalc::DefaultContext->new();
  my $sumFunction = MCalc::Functions::Sum->new();

  my $arg1 = Tree->new("i");
  my $arg2 = Tree->new("i");
  my $arg3 = Tree->new("1");
  my $arg4 = Tree->new("3");
  my $arg5 = Tree->new("");

  throws_ok {
    $sumFunction->evaluate($context, $arg1, $arg2, $arg3, $arg4, $arg5);
  } "Error::Simple";
};

subtest "dies when second parameter is number" => sub {
  my $context = MCalc::DefaultContext->new();
  my $sumFunction = MCalc::Functions::Sum->new();

  my $arg1 = Tree->new("i");
  my $arg2 = Tree->new("1");
  my $arg3 = Tree->new("1");
  my $arg4 = Tree->new("3");

  throws_ok {
    $sumFunction->evaluate($context, $arg1, $arg2, $arg3, $arg4);
  } "Error::Simple";
};

subtest "dies when second parameter is tree" => sub {
  my $context = MCalc::DefaultContext->new();
  my $sumFunction = MCalc::Functions::Sum->new();

  my $arg1 = Tree->new("i");
  my $arg2 = Tree->new("+");
  $arg2->add_child(Tree->new("i"));
  $arg2->add_child(Tree->new("1"));
  my $arg3 = Tree->new("1");
  my $arg4 = Tree->new("3");

  throws_ok {
    $sumFunction->evaluate($context, $arg1, $arg2, $arg3, $arg4);
  } "Error::Simple";
};


done_testing();
