package MCalc::Functions::ArithmeticFunction;

use Moose::Role;
use MCalc::Language;
use List::Util qw(reduce);
use Tree;
use MCalc::Evaluator;

with "MCalc::Evaluateable";

has sign => (isa => "Str",
             is => "ro",
             reader => "getSign",
             required => 1);

requires "doCalculation";

sub evaluate {
  my ($this, $context, @args) = @_;

  my @vals = map { evaluateTree($context, $_) } @args;

  my $result;

  if ($this->onlyNumbers(@vals)) {
    my @plainValues = map { $_->value } @vals;

    $result = Tree->new(reduce { $this->doCalculation($a, $b) } @plainValues);
  } else {
    $result = Tree->new($this->getSign());
    $result->add_child(@vals);
  }

  return $result;
}

sub onlyNumbers {
  my ($this, @trees) = @_;

  return reduce { $this->isNumericValue($a) &&
                    $this->isNumericValue($b) } @trees;
}

sub isNumericValue {
  my ($this, $tree) = @_;

  return $tree->is_leaf() && is_number($tree->value());
}

1;
