package MCalc::Functions::Simplification;

use Moose;
use Tree;
use MCalc::Printer;
use MCalc::Language;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, $treeRef) = @_;

  my $tree = $this->simplify($$treeRef);

  my $printer = MCalc::Printer->new();

  return $printer->to_string($tree);
}

sub simplify {
  my ($this, $tree) = @_;

  # print "simplifying ".join(", ", map { $_->value } $tree->traverse($tree->LEVEL_ORDER))."\n";

  if (is_operator($tree->value)) {
    my $op = $tree->value;
    my $child1 = $this->simplify($tree->children(0));
    my $child2 = $this->simplify($tree->children(1));

    # print $op." child1: ".join(", ", map { $_->value } $child1->traverse($child1->LEVEL_ORDER))."\n";
    # print $op." child2: ".join(", ", map { $_->value } $child2->traverse($child2->LEVEL_ORDER))."\n";

    if ($op eq "*") {
      if ($child2->value eq 1) {
        $tree->remove_child($child1);

        return $child1;
      } elsif ($child1->value eq 1) {
        $tree->remove_child($child2);

        return $child2;
      } elsif ($child1->value eq 0 || $child2->value eq 0) {
        return Tree->new(0);
      } else {
        $tree->remove_child($child1);
        $tree->remove_child($child2);

        my $product = Tree->new("*");
        $product->add_child($child1);
        $product->add_child($child2);

        return $product;
      }
    } elsif ($op eq "+") {
      if ($child1->value eq 0) {
        $tree->remove_child($child2);

        return $child2;
      } elsif ($child2->value eq 0) {
        $tree->remove_child($child1);

        return $child1;
      } else {
        $tree->remove_child($child1);
        $tree->remove_child($child2);

        my $sum = Tree->new("+");
        $sum->add_child($child1);
        $sum->add_child($child2);

        return $sum;
      }
    } else {
      return $tree;
    }
  } else {
    return $tree;
  }
}


1;
