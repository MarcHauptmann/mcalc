package MCalc::Functions::Cotangent;

use MCalc::Evaluator;
use Moose;
use Math::Trig qw(cot);
use Tree;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0])->value();

  return Tree->new(cot($arg));
}

1;
