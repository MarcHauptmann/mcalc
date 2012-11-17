package MCalc::Functions::Ceiling;

use Moose;
use POSIX;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $evaluatorRef, $contextRef, @args) = @_;

  my $arg = $$evaluatorRef->evaluate($contextRef, $args[0]);

  return POSIX::ceil($arg);
}

1;
