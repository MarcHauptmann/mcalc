package MCalc::Functions::Log;

use Moose;
use Math::Complex;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = $$contextRef->evaluate($args[0]);
  my $base = $$contextRef->evaluate($args[1]);

  return logn($arg, $base);
}

1;
