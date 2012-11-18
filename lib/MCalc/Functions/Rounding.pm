package MCalc::Functions::Rounding;

use MCalc::Evaluator;
use Moose;
use POSIX;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = evaluateTree($contextRef, $args[0]);

  return POSIX::floor($arg + 0.5);
}

1;
