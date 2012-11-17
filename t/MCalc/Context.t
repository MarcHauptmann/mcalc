#!/usr/bin/perl

use Test::More;
use Test::Exception;

BEGIN {
  use_ok("MCalc::Context");
}

subtest "Variable can be completed" => sub{
  my $context = MCalc::Context->new();
  $context->setVariable("pi", 3);

  my @completions = $context->getCompletions("p");

  is(scalar(@completions), 1, "one completion");
  is_deeply(\@completions, ["pi"], "variable is completed");
};

subtest "function can be completed" => sub{
  my $context = MCalc::Context->new();
  $context->setFunction("cos", 1); # just a dummy
  $context->setFunction("cot", 1); # just a dummy

  my @completions = $context->getCompletions("co");

  is(scalar(@completions), 2, "one completion");
  is_deeply(\@completions, ["cos", "cot"], "'cos' and 'cot' works");
};

subtest "dies on unknown variable" => sub {
  my $context = MCalc::Context->new();

  throws_ok { $context->getVariable("unknownVar"); } "Error::Simple";
};

subtest "dies on unknown function" => sub {
  my $context = MCalc::Context->new();

  throws_ok { $context->getFunction("unknownFunction"); } "Error::Simple";
};

done_testing();
