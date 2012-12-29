package MCalc::Functions::Sqrt;

use MCalc::Evaluator;
use Moose;
use Math::Complex;
use Tree;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0])->value();

  return Tree->new(sqrt($arg));
}

1;
