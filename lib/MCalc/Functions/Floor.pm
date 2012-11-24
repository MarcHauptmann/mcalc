package MCalc::Functions::Floor;

use MCalc::Evaluator;
use Moose;
use POSIX;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0]);

  return POSIX::floor($arg);
}

1;
