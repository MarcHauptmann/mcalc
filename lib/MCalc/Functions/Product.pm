package MCalc::Functions::Product;

use MCalc::Evaluator;
use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, $expression, $var, $from, $to) = @_;

  my $fromValue = evaluateTree($context, $from);
  my $toValue = evaluateTree($context, $to);
  my $varName = $var->value;

  my $product = 1;

  my $oldVariable = undef;

  if($context->variableIsDefined($varName)) {
    $oldVariable = $context->getVariable($varName);
  }

  for (my $value = $fromValue; $value <= $toValue; $value++) {
    $context->setVariable($varName, $value);

    $product *= evaluateTree($context, $expression);
  }

  $context->setVariable($varName, $oldVariable);

  return $product;
}
