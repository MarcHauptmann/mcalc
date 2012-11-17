package MCalc::Functions::Assignment;

use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  my $var = ${$args[0]}->value();
  my $value = $$contextRef->evaluate($args[1]);

  $$contextRef->setVariable($var, $value);

  return "$var = $value";
}

1;
