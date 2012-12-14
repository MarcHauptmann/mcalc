package MCalc::Functions::Absolute;

use Moose;
use MCalc::Evaluator;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = evaluateTree($contextRef, $args[0])->value();

  return abs($arg);
}

1;
