package MCalc::Functions::Product;

use MCalc::Evaluator;
use MCalc::CompoundContext;
use Moose;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $context, $expression, $var, $from, $to) = @_;

  my $fromValue = evaluateTree($context, $from)->value();
  my $toValue = evaluateTree($context, $to)->value();
  my $varName = $var->value();

  my $product = 1;

  my $productContext = MCalc::CompoundContext->new();
  $productContext->addContext($context);

  for (my $value = $fromValue; $value <= $toValue; $value++) {
    $productContext->setVariable($varName, $value);

    $product *= evaluateTree($productContext, $expression)->value();
  }

  return $product;
}
