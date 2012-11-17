package MCalc::Functions::Negation;

use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $evalatorRef, $contextRef, @args) = @_;

  my $arg = $$evalatorRef->evaluate($contextRef, $args[0]);

  return -$arg;
}

1;
