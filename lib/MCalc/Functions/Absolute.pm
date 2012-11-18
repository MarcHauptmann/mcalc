package MCalc::Functions::Absolute;

use Moose;
use MCalc::Evaluator;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = evaluateTree($contextRef, $args[0]);

  return abs($arg);
}

1;
