package MCalc::Functions::Simplification;

use Moose;
use Tree;
use MCalc::Printer;
use MCalc::Language;
use MCalc::Evaluator;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, $treeRef) = @_;
  my $printer = MCalc::Printer->new();

  my $tree = $this->simplify($contextRef, $$treeRef);

  return $printer->to_string($tree);
}

sub is_numeric_tree {
  my ($this, $context, $tree) = @_;

  if ($tree->size == 1) {
    return is_number($tree->value) ||
      (is_identifier($tree->value) && $context->variableIsDefined($tree->value));
  } elsif (is_operator($tree->value)) {
    return $this->is_numeric_tree($context, $tree->children(0)) &&
      $this->is_numeric_tree($context, $tree->children(1));
  } else {
    return 0;
  }
}

sub simplify_product {
  my ($this, $child1, $child2) = @_;

  if ($child2->value eq 1) {
    return Tree->new($child1->value);
  } elsif ($child1->value eq 1) {
    return Tree->new($child2->value);
  } elsif ($child1->value eq 0 || $child2->value eq 0) {
    return Tree->new(0);
  } else {
    my $product = Tree->new("*");
    $product->add_child($child1->clone);
    $product->add_child($child2->clone);

    return $product;
  }
}

sub simplify_sum {
  my ($this, $child1, $child2) = @_;

  if ($child1->value eq 0) {
    return Tree->new($child2->value);
  } elsif ($child2->value eq 0) {
    return Tree->new($child1->value);
  } else {
    my $sum = Tree->new("+");
    $sum->add_child($child1->clone);
    $sum->add_child($child2->clone);

    return $sum;
  }
}

sub simplify {
  my ($this, $contextRef, $tree) = @_;

  # print "simplifying ".join(", ", map { $_->value } $tree->traverse($tree->LEVEL_ORDER))."\n";

  if ($this->is_numeric_tree($$contextRef, $tree)) {
    return Tree->new(evaluateTree($contextRef, \$tree));
  }

  if (is_operator($tree->value)) {
    my $op = $tree->value;
    my $child1 = $this->simplify($contextRef, $tree->children(0));
    my $child2 = $this->simplify($contextRef, $tree->children(1));

    # print $op." child1: ".join(", ", map { $_->value } $child1->traverse($child1->LEVEL_ORDER))."\n";
    # print $op." child2: ".join(", ", map { $_->value } $child2->traverse($child2->LEVEL_ORDER))."\n";

    if ($op eq "*") {
      return $this->simplify_product($child1, $child2);
    } elsif ($op eq "+") {
      return $this->simplify_sum($child1, $child2);
    } else {
      return $tree;
    }
  } else {
    return $tree;
  }
}


1;
