package MCalc::Functions::Sum;

use MCalc::Evaluator;
use MCalc::CompoundContext;
use Error::Simple;
use Moose;
use Tree;

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
  my $fromValue = evaluateTree($context, $from)->value();
  my $toValue = evaluateTree($context, $to)->value();

  # validate size of second parameter tree (must be one) and is identifiert
  if ($var->size() != 1 || not($varName =~ /[a-zA-Z]+/)) {
    throw Error::Simple "sum: second parameter must be single variable";
  }

  my $sumContext = MCalc::CompoundContext->new();
  $sumContext->addContext($context);

  my $result = 0;

  for (my $i=$fromValue; $i<=$toValue; $i++) {
    $sumContext->setVariable($varName, $i);
    $result += evaluateTree($sumContext, $ex)->value();
  }

  return Tree->new($result);
}

1;
