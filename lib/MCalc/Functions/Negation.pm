package MCalc::Functions::Negation;

use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = $$contextRef->evaluate($args[0]);

  return -$arg;
}

1;
