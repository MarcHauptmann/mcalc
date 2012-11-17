package MCalc::Functions::Rounding;

use Moose;
use POSIX;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = $$contextRef->evaluate($args[0]);

  return POSIX::floor($arg + 0.5);
}

1;
