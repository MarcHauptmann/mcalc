package MCalc::Functions::Sqrt;

use MCalc::Evaluator;
use Moose;
use Math::Complex;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = evaluateTree($contextRef, $args[0]);

  return sqrt($arg);
}

1;
