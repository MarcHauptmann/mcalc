package MCalc::Functions::UserFunction;

use MCalc::Evaluator;
use Moose;
use Error;

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

  my %oldValues = ();

  foreach my $name (@{$this->arguments}) {
    if ($context->variableIsDefined($name)) {
      $oldValues{$name} = $context->getVariable($name);
    } else {
      $oldValues{$name} = undef;
    }
  }

  for (my $i=0; $i<$this->getArgumentCount; $i++) {
    my $argName = ${$this->arguments}[$i];
    my $argValue = evaluateTree($context, $args[$i])->value();

    $context->setVariable($argName, $argValue);
  }

  my $result = evaluateTree($context, $this->body)->value();

  foreach my $name (@{$this->arguments}) {
    $context->setVariable($name, $oldValues{$name});
  }

  return $result;
}

1;
