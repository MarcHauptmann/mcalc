package MCalc::Functions::Division;

use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $v1 = $$contextRef->evaluate($args[0]);
  my $v2 = $$contextRef->evaluate($args[1]);

  return $v1 / $v2;
}

1;
