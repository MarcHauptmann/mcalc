package MCalc::Functions::Ceiling;

use MCalc::Evaluator;
use Moose;
use POSIX;
use Tree;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = evaluateTree($contextRef, $args[0])->value();

  return Tree->new(POSIX::ceil($arg));
}

1;
