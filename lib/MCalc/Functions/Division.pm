package MCalc::Functions::Division;

use MCalc::Evaluator;
use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $v1 = evaluateTree($contextRef, $args[0]);
  my $v2 = evaluateTree($contextRef, $args[1]);

  return $v1 / $v2;
}

1;
