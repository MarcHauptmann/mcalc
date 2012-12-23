package MCalc::Functions::Negation;

use MCalc::Evaluator;
use Moose;
use Tree;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0])->value();

  return Tree->new(-$arg);
}

1;
