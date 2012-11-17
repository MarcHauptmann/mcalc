package MCalc::Functions::Log;

use Moose;
use Math::Complex;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $evaluatorRef, $contextRef, @args) = @_;

  my $arg = $$evaluatorRef->evaluate($contextRef, $args[0]);
  my $base = $$evaluatorRef->evaluate($contextRef, $args[1]);

  return logn($arg, $base);
}

1;
