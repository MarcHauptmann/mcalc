package Evaluator;

use Moose;
use Tree;

sub evaluate {
  my ($this, $contextRef, $treeRef) = @_;
  my $context = $$contextRef;
  my $tree = $$treeRef;
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

    my @args = map { \$_ } $tree->children();

    # return &{$func}(\$this, @args);
    return $func->evaluate(\$this, $contextRef, @args);
  }
}

1;
