package MCalc::Functions::Sum;

use MCalc::Evaluator;
use Error::Simple;
use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, @args) = @_;

  # validate parameter count
  if (scalar(@args) != 4) {
    throw Error::Simple "sum: argument count does not match";
  }

  # parameters
  my ($ex, $var, $from, $to) = @args;

  my $varName = $var->value();
  my $fromValue = evaluateTree($context, $from);
  my $toValue = evaluateTree($context, $to);

  # validate size of second parameter tree (must be one) and is identifiert
  if ($var->size() != 1 || not($varName =~ /[a-zA-Z]+/)) {
    throw Error::Simple "sum: second parameter must be single variable";
  }

  my $oldVar = undef;
  my $result = 0;

  # ggf. alten Wert von Laufvariable sichern
  if ($context->variableIsDefined($varName)) {
    $oldVar = $context->getVariable($varName);
  }

  for (my $i=$fromValue; $i<=$toValue; $i++) {
    $context->setVariable($varName, $i);
    $result += evaluateTree($context, $ex);
  }

  $context->setVariable($varName, $oldVar);

  return $result;
}

1;
