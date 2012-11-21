#!/usr/bin/perl

use Test::More;
use Test::Exception;
use MCalc::Util::TreeBuilder;
use MCalc::DefaultContext;

BEGIN {
  use_ok("MCalc::Functions::SimpleFunction");
}

subtest "function code can be defined" => sub {
  my $context = MCalc::DefaultContext->new();
  my $function = MCalc::Functions::SimpleFunction->new( code => sub { 2*$_[0] });

  my $result = $function->evaluate(\$context, \tree("2"));

  is($result, 4, "result ist 4");
};

subtest "number of arguments can be validated" => sub {
  my $context = MCalc::DefaultContext->new();
  my $function = MCalc::Functions::SimpleFunction->new( code => sub { 2 },
                                                        argumentCount => 1);

  throws_ok { $function->evaluate(\$context, \tree("2"), \tree("3")) }
    "Error::Simple", "too many arguments throw exception";

  throws_ok { $function->evaluate(\$context) }
    "Error::Simple", "too few arguments throw exception";
};

done_testing();
