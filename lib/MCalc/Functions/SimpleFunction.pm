package MCalc::Functions::SimpleFunction;

use Moose;
use MCalc::Evaluator;
use Error::Simple;

with "MCalc::Evaluateable";

has "code" => (isa => "CodeRef",
               is => "rw");

has argumentCount => (isa => "Int",
                      is => "rw",
                      default => 1);

has argumentNames => (isa => "ArrayRef",
                      is => "rw",
                      default => sub { ["x"] });

sub evaluate {
  my ($this, $context, @argTrees) = @_;

  if (scalar(@argTrees) != $this->argumentCount()) {
    throw Error::Simple "argument count does not match";
  }

  my @args = map {evaluateTree($context, $_)} @argTrees;

  return &{$this->code}(@args);
}

1;
