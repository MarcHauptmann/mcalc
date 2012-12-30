package MCalc::Functions::UserFunction;

use MCalc::Evaluator;
use Moose;
use Error;
use Tree;
use MCalc::CompoundContext;

with "MCalc::Evaluateable";

has arguments => (isa => "ArrayRef",
                  is => "rw");

has body => (isa => "Ref",
             is => "rw");

has name => (isa => "Str",
             is => "rw",
             default => "");

sub getArgumentCount {
  my ($this) = @_;

  return scalar(@{$this->arguments});
}

sub evaluate {
  my ($this, $context, @args) = @_;

  if ($this->getArgumentCount() != scalar(@args)) {
    throw Error::Simple $this->name.": argument count does not match";
  }

  my $privateContext = MCalc::CompoundContext->new();
  $privateContext->addContext($context);

  for (my $i=0; $i<$this->getArgumentCount; $i++) {
    my $argName = ${$this->arguments}[$i];
    my $argValue = evaluateTree($context, $args[$i])->value();

    $privateContext->setVariable($argName, $argValue);
  }

  my $result = evaluateTree($privateContext, $this->body)->value();

  return Tree->new($result);
}

1;
