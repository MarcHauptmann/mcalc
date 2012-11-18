package MCalc::Functions::Log;

use MCalc::Evaluator;
use Moose;
use Math::Complex;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = evaluateTree($contextRef, $args[0]);
  my $base = evaluateTree($contextRef, $args[1]);

  return logn($arg, $base);
}

1;
