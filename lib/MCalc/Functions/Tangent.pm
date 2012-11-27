package MCalc::Functions::Tangent;

use MCalc::Evaluator;
use Moose;
use Math::Trig qw(tan);

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0]);

  return tan($arg);
}

1;
