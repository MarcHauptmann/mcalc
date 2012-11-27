package MCalc::Functions::Division;

use MCalc::Evaluator;
use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $v1 = evaluateTree($context, $args[0]);
  my $v2 = evaluateTree($context, $args[1]);

  return $v1 / $v2;
}

1;
