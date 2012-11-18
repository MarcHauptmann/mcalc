package MCalc::Functions::Sine;

use MCalc::Evaluator;
use Moose;
use Math::Trig;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = evaluateTree($contextRef, $args[0]);

  return sin($arg);
}

1;
