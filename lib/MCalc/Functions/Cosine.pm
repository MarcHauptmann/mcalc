package MCalc::Functions::Cosine;

use MCalc::Evaluator;
use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0])->value();

  return cos($arg);
}

1;
