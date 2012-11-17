package MCalc::Functions::Sqrt;

use Moose;
use Math::Complex;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $evaluatorRef, $contextRef, @args) = @_;

  my $arg = $$evaluatorRef->evaluate($contextRef, $args[0]);

  return sqrt($arg);
}

1;
