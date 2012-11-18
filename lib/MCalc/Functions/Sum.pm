package MCalc::Functions::Sum;

use MCalc::Evaluator;
use Error::Simple;
use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, @args) = @_;

  # validate parameter count
  if (scalar(@args) != 4) {
    throw Error::Simple "sum: argument count does not match";
  }

  # parameters
  my ($exRef, $varRef, $fromRef, $toRef) = @args;

  my $var = $$varRef->value();
  my $from = evaluateTree($contextRef, $fromRef);
  my $to = evaluateTree($contextRef, $toRef);

  # validate size of second parameter tree (must be one) and is identifiert
  if ($$varRef->size() != 1 || not($$varRef->value =~ /[a-zA-Z]+/)) {
    throw Error::Simple "sum: second parameter must be single variable";
  }

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
