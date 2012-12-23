package MCalc::Functions::Ln;

use MCalc::Evaluator;
use Moose;
use Tree;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0])->value();

  return Tree->new(log($arg));
}

1;
