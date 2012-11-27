package MCalc::Functions::Sqrt;

use MCalc::Evaluator;
use Moose;
use Math::Complex;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0]);

  return sqrt($arg);
}

1;
