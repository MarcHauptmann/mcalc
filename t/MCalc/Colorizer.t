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
  $colorizer->setBraceStyles(["bold green", "bold blue"]);

  my $expected = colored("(", "bold green").colored(")", "bold green");

  is($colorizer->colorize("()"), $expected, "braces are colorized");
}

sub brace_colors_are_repeated : Tests {
  my $colorizer = MCalc::Colorizer->new();
  $colorizer->setBraceStyles(["green", "blue"]);

  my $expected = colored("(", "green").colored("(", "blue").colored("(", "green");

  is($colorizer->colorize("((("), $expected, "braces are colorized");
}

sub functions_are_underlined_by_default : Tests {
  my $context = MCalc::SimpleContext->new();
  $context->setFunction("sin", MCalc::Functions::UserFunction->new());

  my $colorizer = MCalc::Colorizer->new();
  $colorizer->setBraceStyles(["bold green", "bold blue"]);
  $colorizer->setContext($context);

  my $expected = colored("sin", "underline bold").colored("(", "bold green")."1".colored(")", "bold green");

  is($colorizer->colorize("sin(1)"), $expected, "function name is underlined");
}

sub unknown_identifiers_can_be_colored_red : Tests {
  my $context = MCalc::SimpleContext->new();
  my $colorizer = MCalc::Colorizer->new();
  $colorizer->setBraceStyles(["bold green", "bold blue"]);
  $colorizer->setUnknownStyle("red");
  $colorizer->setContext($context);

  my $expected = colored("sin", "red").colored("(", "bold green")."1".colored(")", "bold green");

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

sub braces_are_highlighted : Tests {
  my $context = MCalc::SimpleContext->new();

  my $colorizer = MCalc::Colorizer->new();
  $colorizer->setContext($context);
  $colorizer->setBraceHighlightStyles(["red"]);
  $colorizer->setUnknownStyle("bright_white");

  my $expected = colored("sin", "bright_white").colored("(", "red")."3".colored(")", "red");

  is($colorizer->colorize("sin(3)", 3), $expected);
  is($colorizer->colorize("sin(3)", 6), $expected);
}

################################################################################

sub brace_level_can_be_determined : Tests {
  my $colorizer = MCalc::Colorizer->new();

  is($colorizer->_determineBraceLevel("sin(x)", 3), 0, "opening brace increases level");
  is($colorizer->_determineBraceLevel("sin(x)", 6), 0, "closing brace decreases level");
  is($colorizer->_determineBraceLevel("sin(x)", 1), -1, "level -1 by default");
}

Test::Class->runtests;

