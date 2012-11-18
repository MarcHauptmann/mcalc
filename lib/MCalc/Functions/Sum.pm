package MCalc::Functions::Sum;

use MCalc::Evaluator;
use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, $exRef, $varRef, $fromRef, $toRef) = @_;

  my $var = $$varRef->value();
  my $from = evaluateTree($contextRef, $fromRef);
  my $to = evaluateTree($contextRef, $toRef);

  my $oldVar = undef;
  my $result = 0;

  # ggf. alten Wert von Laufvariable sichern
  if ($$contextRef->variableIsDefined($var)) {
    $oldVar = $$contextRef->getVariable($var);
  }

  for (my $i=$from; $i<=$to; $i++) {
    $$contextRef->setVariable($var, $i);
    $result += evaluateTree($contextRef, $exRef);
  }

  $$contextRef->setVariable($var, $oldVar);

  return $result;
}

1;
