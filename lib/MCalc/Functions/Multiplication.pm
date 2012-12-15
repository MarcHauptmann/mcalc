package MCalc::Functions::Multiplication;

use MCalc::Evaluator;
use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $v1 = evaluateTree($context, $args[0])->value();
  my $v2 = evaluateTree($context, $args[1])->value();

  return $v1 * $v2;
}

1;
