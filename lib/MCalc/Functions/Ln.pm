package MCalc::Functions::Ln;

use MCalc::Evaluator;
use Moose;
use Math::Complex;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = evaluateTree($contextRef, $args[0]);

  return log($arg);
}

1;
