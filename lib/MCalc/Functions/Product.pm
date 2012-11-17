package MCalc::Functions::Product;

use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $evaluatorRef, $contextRef, $expression, $varRef, $fromRef, $toRef) = @_;

  my $from = $$evaluatorRef->evaluate($contextRef, $fromRef);
  my $to = $$evaluatorRef->evaluate($contextRef, $toRef);
  my $var = $$varRef->value;

  my $product = 1;

  my $oldVariable = undef;

  if($$contextRef->variableIsDefined($var)) {
    $oldVariable = $$contextRef->getVariable($var);
  }

  for (my $value = $from; $value <= $to; $value++) {
    $$contextRef->setVariable($var, $value);

    $product *= $$evaluatorRef->evaluate($contextRef, $expression);
  }

  $$contextRef->setVariable($var, $oldVariable);

  return $product;
}
