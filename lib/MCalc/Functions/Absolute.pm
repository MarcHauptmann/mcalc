package MCalc::Functions::Absolute;

use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $arg = $$contextRef->evaluate($args[0]);

  return abs($arg);
}

1;
