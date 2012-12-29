package MCalc::Functions::Log;

use MCalc::Evaluator;
use Moose;
use Math::Complex qw(logn);
use Tree;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0])->value();
  my $base = evaluateTree($context, $args[1])->value();

  return Tree->new(logn($arg, $base));
}

1;
