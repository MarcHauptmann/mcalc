package MCalc::Functions::Floor;

use MCalc::Evaluator;
use Moose;
use POSIX;
use Tree;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  my $arg = evaluateTree($context, $args[0])->value();

  return Tree->new(POSIX::floor($arg));
}

1;
