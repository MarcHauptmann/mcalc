package MCalc::Evaluator;

use Exporter;
use Tree;

@ISA = qw(Exporter);
@EXPORT= qw(evaluateTree);

sub evaluateTree {
  my ($context, $tree) = @_;
  my $val = $tree->value();

  # wenn am Ende
  if ($tree->size() == 1) {
    if ($val =~ /[a-zA-Z]+/) {
      # Variable
      return $context->getVariable($val);
    } else {
      # Zahl
      return $val;
    }
  } else {
    # Funktionsaufruf
    my $func = $context->getFunction($tree->value());

    return $func->evaluate($context, $tree->children);
  }
}

1;
