package MCalc::Functions::Product;

use MCalc::Evaluator;
use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, $expression, $varRef, $fromRef, $toRef) = @_;

  my $from = evaluateTree($contextRef, $fromRef);
  my $to = evaluateTree($contextRef, $toRef);
  my $var = $$varRef->value;

  my $product = 1;

  my $oldVariable = undef;

  if($$contextRef->variableIsDefined($var)) {
    $oldVariable = $$contextRef->getVariable($var);
  }

  for (my $value = $from; $value <= $to; $value++) {
    $$contextRef->setVariable($var, $value);

    $product *= evaluateTree($contextRef, $expression);
  }

  $$contextRef->setVariable($var, $oldVariable);

  return $product;
}
