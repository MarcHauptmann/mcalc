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
    # Variable
    if ($val =~ /[a-zA-Z]+/) {
      if ($context->variableIsDefined($val)) {
        return Tree->new($context->getVariable($val));
      } else {
        return Tree->new($val);
      }
    } else {
      # Zahl
      return Tree->new($val);
    }
  } else {
    # Funktionsaufruf
    my $func = $context->getFunction($tree->value());

    my $result = $func->evaluate($context, $tree->children);

    if (defined($result)) {
      return Tree->new($result);
    } else {
      return undef;
    }
  }
}

1;
