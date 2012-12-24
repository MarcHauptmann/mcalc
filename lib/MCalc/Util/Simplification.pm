package MCalc::Util::Simplification;

use Exporter;
use Error::Simple;
use MCalc::Language;

@ISA = qw(Exporter);
@EXPORT = qw(rule_matches extract_values substitute complexity);
@EXPORT_OK = qw(trees_equal);

sub rule_matches {
  my ($rule, $expression, $valRef) = @_;

  if (not(defined($valRef))) {
    $valRef = {};
  }

  if ($expression->is_leaf()) {
    # check whether a variable is set
    if (is_identifier($rule->value())) {
      if (defined($valRef->{$rule->value()})) {
        return trees_equal($valRef->{$rule->value()}, $expression);
      } else {
	$valRef->{$rule->value()} = $expression->clone();
      }

      return 1;
    } elsif ($rule->value() eq $expression->value) {
      return 1;
    } else {
      return 0;
    }
  } else {
    if (is_identifier($rule->value())) {
      return 1;
    } elsif ($rule->value() eq $expression->value) {
      return rule_matches($rule->children(0), $expression->children(0), $valRef)
        && rule_matches($rule->children(1), $expression->children(1), $valRef);
    } else {
      return 0;
    }
  }
}

sub extract_values {
  my ($rule, $expression) = @_;

  my %values = ();

  if (is_identifier($rule->value())) {
    $values{$rule->value()} = $expression->clone();
  } elsif ($rule->size() > 1) {
    my %leftValues = extract_values($rule->children(0), $expression->children(0));
    my %rightValues = extract_values($rule->children(1), $expression->children(1));

    merge_values(\%values, \%leftValues);
    merge_values(\%values, \%rightValues);
  }

  return %values;
}

sub merge_values {
  my ($valRef, $newValueRef) = @_;

  foreach my $key (keys %$newValueRef) {
    my $val = $newValueRef->{$key};

    if (defined($valRef->{$key}) && not(trees_equal($valRef->{$key}, $val))) {
      throw Error::Simple "redefinition of variable ".$key;
    }

    $valRef->{$key} = $val;
  }
}

sub substitute {
  my ($expression, %values) = @_;

  if ($expression->size() == 1) {
    foreach my $variable (keys %values) {
      if ($variable eq $expression->value()) {
        return $values{$variable};
      }
    }
  } else {
    for (my $i = 0; $i<scalar($expression->children); $i++) {
      my $newChild = substitute($expression->children($i), %values);

      $expression->remove_child($i);
      $expression->add_child({ at => $i }, $newChild);
    }
  }

  return $expression;
}

sub trees_equal {
  my ($leftTree, $rightTree) = @_;

  my $valuesEqual = $leftTree->value() eq $rightTree->value();
  my $childCountEqual = scalar($leftTree->children()) == scalar($rightTree->children());

  if ($leftTree->is_leaf() && $rightTree->is_leaf()) {
    return $valuesEqual;
  } elsif ($valuesEqual && $childCountEqual) {
    for (my $i = 0; $i < scalar($leftTree->children()); $i++) {
      my $leftChild = $leftTree->children($i);
      my $rightChild = $rightTree->children($i);

      if (not(trees_equal($leftChild, $rightChild))) {
        return 0;
      }
    }

    return 1;
  } else {
    return 0;
  }
}

sub complexity {
  my ($tree) = @_;

  return $tree->size;
}
1;
