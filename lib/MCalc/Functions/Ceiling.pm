package MCalc::Functions::Ceiling;

use Moose;
use POSIX;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = $$contextRef->evaluate($args[0]);

  return POSIX::ceil($arg);
}

1;
