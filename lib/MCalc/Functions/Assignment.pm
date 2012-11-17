package MCalc::Functions::Assignment;

use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $evaluatorRef, $contextRef, @args) = @_;

  my $var = ${$args[0]}->value();
  my $value = $$evaluatorRef->evaluate($contextRef, $args[1]);

  $$contextRef->setVariable($var, $value);

  return "$var = $value";
}

1;
