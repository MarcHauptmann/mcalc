package MCalc::CompoundContext;

use Moose;

with "MCalc::Context";

has "subcontexts" => (isa => "ArrayRef",
                      is => "rw",
                      default => sub { return [] });

has myContext => (isa => "MCalc::SimpleContext",
                  is => "rw",
                  default => sub { return MCalc::SimpleContext->new() });

sub addContext {
  my ($this, $context) = @_;

  push @{$this->subcontexts}, $context;
}

sub getVariable {
  my ($this, $key) = @_;

  if ($this->myContext->variableIsDefined($key)) {
    return $this->myContext->getVariable($key);
  }

  foreach my $context (@{$this->subcontexts}) {
    if ($context->variableIsDefined($key)) {
      return $context->getVariable($key);
    }
  }
}

sub setVariable {
  my ($this, $key, $value) = @_;

  $this->myContext->setVariable($key, $value);
}

sub variableIsDefined  {
  my ($this, $key) = @_;

  foreach my $context (@{$this->subcontexts}) {
    if ($context->variableIsDefined($key)) {
      return 1;
    }
  }

  return $this->myContext->variableIsDefined($key);
}

sub getFunction {
  my ($this, $key) = @_;

  if ($this->myContext->functionIsDefined($key)) {
    return $this->myContext->getFunction($key);
  }

  foreach my $context (@{$this->subcontexts}) {
    if ($context->functionIsDefined($key)) {
      return $context->getFunction($key);
    }
  }

  return 0;
}

sub setFunction {
  my ($this, $key, $function) = @_;

  $this->myContext->setFunction($key, $function);
}

sub functionIsDefined {
  my ($this, $key) = @_;

  foreach my $context (@{$this->subcontexts}) {
    if ($context->functionIsDefined($key)) {
      return 1;
    }
  }
}

sub getCompletions {
  my ($this, $str) = @_;

  my @completions = $this->myContext->getCompletions($str);

  foreach my $context (@{$this->subcontexts}) {
    push @completions, $context->getCompletions($str);
  }

  return @completions;
}

1;
