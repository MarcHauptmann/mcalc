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
  my ($this, $contextRef, @argTreeRefs) = @_;

  if (scalar(@argTreeRefs) != $this->argumentCount()) {
    throw Error::Simple "argument count does not match";
  }

  my @args = map {evaluateTree($contextRef, $_)} @argTreeRefs;

  return &{$this->code}(@args);
}

1;
