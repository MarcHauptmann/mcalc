#!/usr/bin/perl

use Test::More;
use MCalc::SimpleContext;
use MCalc::Functions::SimpleFunction;

BEGIN {
  use_ok("MCalc::CompoundContext");
}

subtest "a variable in subcontext can be accessed" => sub {
  my $subcontext = MCalc::SimpleContext->new();
  $subcontext->setVariable("test", 123);

  my $context = MCalc::CompoundContext->new();
  $context->addContext($subcontext);

  ok($context->variableIsDefined("test"), "variable is defined");
  is($context->getVariable("test"), 123, "variable can be accessed");
};

subtest "variables in subcontexts can be overridden" => sub {
  my $subcontext = MCalc::SimpleContext->new();
  $subcontext->setVariable("test", 123);

  my $context = MCalc::CompoundContext->new();
  $context->addContext($subcontext);

  # override variable
  $context->setVariable("test", -1);

  is($context->getVariable("test"), -1, "variable is overridden");

  # use old variable again
  $context->setVariable("test", undef);

  is($context->getVariable("test"), 123, "old variable is used again");
};

subtest "a function in sibcontext can be accessed" => sub {
  my $function = MCalc::Functions::SimpleFunction->new();
  my $subcontext = MCalc::SimpleContext->new();
  $subcontext->setFunction("test", $function);

  my $context = MCalc::CompoundContext->new();
  $context->addContext($subcontext);

  ok($context->functionIsDefined("test"), "function is defined");
  is($context->getFunction("test"), $function, "function can be accessed");
};

subtest "functions in subcontexts can be overridden" => sub {
  my $function1 = MCalc::Functions::SimpleFunction->new(name => "f1");
  my $function2 = MCalc::Functions::SimpleFunction->new(name => "f2");
  my $subcontext = MCalc::SimpleContext->new();
  $subcontext->setFunction("test", $function1);

  my $context = MCalc::CompoundContext->new();
  $context->addContext($subcontext);

  # override variable
  $context->setFunction("test", $function2);

  is_deeply($context->getFunction("test"), $function2, "variable is overridden");

  # use old variable again
  $context->setVariable("test", undef);

  is_deeply($context->getFunction("test"), $function1, "old variable is used again");
};

done_testing();
