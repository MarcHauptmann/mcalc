package MCalc::Functions::Ln;

use Moose;
use Math::Complex;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = $$contextRef->evaluate($args[0]);

  return log($arg);
}

1;
