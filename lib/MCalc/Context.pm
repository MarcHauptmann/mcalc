package MCalc::Context;

use Moose;

use MCalc::Functions::Addition;
use MCalc::Functions::Multiplication;
use MCalc::Functions::Subtraction;
use MCalc::Functions::Division;
use MCalc::Functions::Power;
use MCalc::Functions::Cosine;
use MCalc::Functions::Sine;
use MCalc::Functions::Tangent;
use MCalc::Functions::Cotangent;
use MCalc::Functions::Assignment;
use MCalc::Functions::Sum;
use MCalc::Functions::Absolute;
use MCalc::Functions::Negation;
use MCalc::Functions::Floor;
use MCalc::Functions::Ceiling;
use MCalc::Functions::Rounding;
use MCalc::Functions::Sqrt;
use MCalc::Functions::Log;
use MCalc::Functions::Ln;

has "variables" => (is => "rw",
                    isa => "HashRef",
                    default => sub { {} }
                   );

has "functions" => (is => "rw",
                    isa => "HashRef",
                    default => sub { {} }
                   );

sub BUILD {
  my $this = shift;

  # Variablen definieren
  $this->setVariable("pi", 3.1415);
  $this->setVariable("e", exp(1));

  # Funktionen definieren
  $this->setFunction("+", MCalc::Functions::Addition->new());
  $this->setFunction("*", MCalc::Functions::Multiplication->new());
  $this->setFunction("-", MCalc::Functions::Subtraction->new());
  $this->setFunction("/", MCalc::Functions::Division->new());
  $this->setFunction("^", MCalc::Functions::Power->new());
  $this->setFunction("=", MCalc::Functions::Assignment->new());
  $this->setFunction("abs", MCalc::Functions::Absolute->new());
  $this->setFunction("floor", MCalc::Functions::Floor->new());
  $this->setFunction("ceil", MCalc::Functions::Ceiling->new());
  $this->setFunction("round", MCalc::Functions::Rounding->new());
  $this->setFunction("cos", MCalc::Functions::Cosine->new());
  $this->setFunction("cot", MCalc::Functions::Cotangent->new());
  $this->setFunction("tan", MCalc::Functions::Tangent->new());
  $this->setFunction("sin", MCalc::Functions::Sine->new());
  $this->setFunction("sqrt", MCalc::Functions::Sqrt->new());
  $this->setFunction("ln", MCalc::Functions::Ln->new());
  $this->setFunction("log", MCalc::Functions::Log->new());
  $this->setFunction("neg", MCalc::Functions::Negation->new());
  $this->setFunction("sum", MCalc::Functions::Sum->new());
}

sub getVariable {
  my ($this, $key) = @_;

  my $value = ${$this->variables}{$key};

  if (defined($value)) {
    return $value;
  } else {
    die "unknown variable: $key";
  }
}

sub variableIsDefined {
  my ($this, $key) = @_;

  return defined(${$this->variables}{$key});
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
    die "unknown function: $key";
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
