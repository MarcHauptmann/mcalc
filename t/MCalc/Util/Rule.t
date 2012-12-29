#!/usr/bin/perl

use Test::More;
use MCalc::Parser;

BEGIN {
  use_ok("MCalc::Util::Rule");
}

our $parser = MCalc::Parser->new();

subtest "a simple rule can be applied" => sub {
  my $rule = MCalc::Util::Rule->new("a*1=a");
  my $expresssion = $parser->parse("x*1");
  my $expected = $parser->parse("x");

  is_deeply($rule->apply($expresssion), $expected);
};

subtest "a rule for associativity can be applied" => sub {
  my $rule = MCalc::Util::Rule->new("(a*b)*c=a*(b*c)");
  my $expresssion = $parser->parse("(1*2)*3");

  my $result = $rule->apply($expresssion);
  my $expected = $parser->parse("1*(2*3)");

  is_deeply($result, $expected);
};

done_testing();
