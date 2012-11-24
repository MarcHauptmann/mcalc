package MCalc::Functions::Log;

use MCalc::Evaluator;
use Moose;
use Math::Complex;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0]);
  my $base = evaluateTree($context, $args[1]);

  return logn($arg, $base);
}

1;
