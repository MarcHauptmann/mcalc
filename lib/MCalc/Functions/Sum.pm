package MCalc::Functions::Sum;

use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $evaluatorRef, $contextRef, $exRef, $varRef, $fromRef, $toRef) = @_;

  my $var = $$varRef->value();
  my $from = $$evaluatorRef->evaluate($contextRef, $fromRef);
  my $to = $$evaluatorRef->evaluate($contextRef, $toRef);

  my $oldVar = undef;
  my $result = 0;

  # ggf. alten Wert von Laufvariable sichern
  if ($$contextRef->variableIsDefined($var)) {
    $oldVar = $$contextRef->getVariable($var);
  }

  for (my $i=$from; $i<=$to; $i++) {
    $$contextRef->setVariable($var, $i);
    $result += $$evaluatorRef->evaluate($contextRef, $exRef);
  }

  $$contextRef->setVariable($var, $oldVar);

  return $result;
}

1;
