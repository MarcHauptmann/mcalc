package MCalc::Functions::UserFunction;

use Moose;

with "MCalc::Evaluateable";

has arguments => (isa => "ArrayRef",
                  is => "rw");

has body => (isa => "Ref",
             is => "rw");

sub evaluate {
  my ($this, $evaluatorRef, $contextRef, @args) = @_;

  my %oldValues = ();

  foreach my $name (@{$this->arguments}) {
    if ($$contextRef->variableIsDefined($name)) {
      $oldValues{$name} = $$contextRef->getVariable($name);
    } else {
      $oldValues{$name} = undef;
    }
  }

  for (my $i=0; $i<scalar(@{$this->arguments}); $i++) {
    my $argName = ${$this->arguments}[$i];
    my $argValue = $$evaluatorRef->evaluate($contextRef, $args[$i]);

    $$contextRef->setVariable($argName, $argValue);
  }

  my $result = $$evaluatorRef->evaluate($contextRef, \$this->body);

  foreach my $name (@{$this->arguments}) {
    $$contextRef->setVariable($name, $oldValues{$name});
  }

  return $result;
}

1;
