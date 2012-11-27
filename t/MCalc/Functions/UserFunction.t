#!/usr/bin/perl

use Test::More;
use Test::Exception;
use MCalc::Evaluator;
use MCalc::DefaultContext;
use Tree;

BEGIN {
  use_ok("MCalc::Functions::UserFunction");
}

subtest "function can be evaluated" => sub {
  my $context = MCalc::DefaultContext->new();

  my $func = MCalc::Functions::UserFunction->new(arguments => ["x"],
                                                 body => Tree->new("x"));

  my $arg = Tree->new(2);

  my $result = $func->evaluate($context, $arg);

  is($result, 2, "result is 2");
};

subtest "variables are not redefined" => sub {
  my $context = MCalc::DefaultContext->new();

  my $func = MCalc::Functions::UserFunction->new(arguments => ["x"],
                                                 body => Tree->new("x"));

  my $arg = Tree->new(2);

  $context->setVariable("x", 5);

  my $result = $func->evaluate($context, $arg);

  is($context->getVariable("x"), 5, "x is not redefined");
};

subtest "two parameters can be handled" => sub {
  my $context = MCalc::DefaultContext->new();

  my $body = Tree->new("+");
  $body->add_child(Tree->new("x"));
  $body->add_child(Tree->new("y"));

  my $func = MCalc::Functions::UserFunction->new(arguments => ["x", "y"],
                                                 body => $body);

  my $arg1 = Tree->new(2);
  my $arg2 = Tree->new(3);

  my $result = $func->evaluate($context, $arg1, $arg2);

  is($result, 5, "result is 5");
};

subtest "throws error with too few parameters" => sub {
  my $context = MCalc::DefaultContext->new();

  my $func = MCalc::Functions::UserFunction->new(arguments => ["x", "y"],
                                                 body => Tree->new("x"));

  my $arg = Tree->new(2);

  throws_ok { $func->evaluate($context, $arg) } "Error::Simple";
};

subtest "throws error with too many parameters" => sub {
  my $context = MCalc::DefaultContext->new();

  my $func = MCalc::Functions::UserFunction->new(arguments => ["x"],
                                                 body => Tree->new("x"));

  my $arg = Tree->new(2);

  throws_ok { $func->evaluate($context, $arg, $arg) } "Error::Simple";
};

done_testing();
