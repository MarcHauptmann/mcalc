package MCalc::Functions::Rounding;

use Moose;
use POSIX;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $evaluatorRef, $contextRef, @args) = @_;

  my $arg = $$evaluatorRef->evaluate($contextRef, $args[0]);

  return POSIX::floor($arg + 0.5);
}

1;
