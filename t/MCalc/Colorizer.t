#!/usr/bin/perl

use Test::More;
use base qw(Test::Class);
use Term::ANSIColor;
use MCalc::SimpleContext;
use MCalc::Functions::UserFunction;

BEGIN {
  use_ok("MCalc::Colorizer");
}

sub braces_are_colored_bold : Tests {
  my $colorizer = MCalc::Colorizer->new();
  $colorizer->setBraceColors(["green", "blue"]);

  my $expected = colored("(", "green bold").colored(")", "green bold");

  is($colorizer->colorize("()"), $expected, "braces are colorized");
}

sub functions_are_underlined_by_default : Tests {
  my $context = MCalc::SimpleContext->new();
  $context->setFunction("sin", MCalc::Functions::UserFunction->new());

  my $colorizer = MCalc::Colorizer->new();
  $colorizer->setBraceColors(["green", "blue"]);
  $colorizer->setContext($context);

  my $expected = colored("sin", "underline bold").colored("(", "green bold")."1".colored(")", "green bold");

  is($colorizer->colorize("sin(1)"), $expected, "function name is underlined");
}

sub unknown_identifiers_can_be_colored_red : Tests {
  my $context = MCalc::SimpleContext->new();
  my $colorizer = MCalc::Colorizer->new();
  $colorizer->setBraceColors(["green", "blue"]);
  $colorizer->setUnknownStyle("red");
  $colorizer->setContext($context);

  my $expected = colored("sin", "red").colored("(", "green bold")."1".colored(")", "green bold");

  is($colorizer->colorize("sin(1)"), $expected, "unknown function name is red");
}

sub variables_are_bold_by_default : Tests {
  my $context = MCalc::SimpleContext->new();
  $context->setVariable("pi", 3);

  my $colorizer = MCalc::Colorizer->new();
  $colorizer->setContext($context);

  my $expected = colored("pi", "bold");

  is($colorizer->colorize("pi"), $expected, "variable is bold");
}

sub keyword_can_be_colored : Tests {
  my $context = MCalc::SimpleContext->new();

  my $colorizer = MCalc::Colorizer->new();
  $colorizer->setContext($context);
  $colorizer->setKeywordStyle("blue bold");

  my $expected = colored("quit", "blue bold");

  is($colorizer->colorize("quit"), $expected, "keyword is bold blue");
}

Test::Class->runtests;

