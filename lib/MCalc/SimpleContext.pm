package MCalc::SimpleContext;

use Moose;
use Error::Simple;

with "MCalc::Context";

has "variables" => (is => "rw",
                    isa => "HashRef",
                    default => sub { {} }
                   );

has "functions" => (is => "rw",
                    isa => "HashRef",
                    default => sub { {} }
                   );
sub getVariable {
  my ($this, $key) = @_;

  my $value = ${$this->variables}{$key};

  if (defined($value)) {
    return $value;
  } else {
    throw Error::Simple "unknown variable: $key";
  }
}

sub variableIsDefined {
  my ($this, $key) = @_;

  return defined(${$this->variables}{$key});
}

sub functionIsDefined {
  my ($this, $key) = @_;

  return defined(${$this->functions}{$key});
}

sub setVariable {
  my ($this, $key, $value) = @_;

  ${$this->variables}{$key} = $value;
}

sub getFunction {
  my ($this, $key) = @_;

  my $function = ${$this->functions}{$key};

  if (defined($function)) {
    return $function;
  } else {
    throw Error::Simple "unknown function: $key";
  }
}

sub setFunction {
  my ($this, $key, $ref) = @_;

  ${$this->functions}{$key} = $ref;
}

sub getCompletions {
  my $this = shift;
  my @values = ();

  foreach my $val (keys %{$this->variables}) {
    if ($val =~ /^$_[0]/) {
      push @values, $val;
    }
  }

  foreach my $val (keys %{$this->functions}) {
    if ($val =~ /^$_[0]/) {
      push @values, $val;
    }
  }

  return @values;
}

1;
