package MCalc::Functions::Tangent;

use MCalc::Evaluator;
use Moose;
use Math::Trig qw(tan);
use Tree;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0])->value();

  return Tree->new(tan($arg));
}

1;
