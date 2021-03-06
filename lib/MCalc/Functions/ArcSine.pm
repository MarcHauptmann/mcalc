package MCalc::Functions::ArcSine;

use MCalc::Evaluator;
use Math::Trig;
use Tree;
use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg =  evaluateTree($context, $args[0])-value();

  return Tree->new(asin($arg));
}
