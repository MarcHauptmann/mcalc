package MCalc::Functions::Addition;

use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $evaluatorRef, $contextRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($contextRef, $args[0]);
  my $v2 = $$evaluatorRef->evaluate($contextRef, $args[1]);

  return $v1 + $v2;
}

1;
