package Evaluator;

use Moose;
use Tree;
use Math::Complex;
use SimpleFunctions;
use TrigonometricFunctions;

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

  # Funktionen definieren
  $this->setFunction("+", \&SimpleFunctions::plus);
  $this->setFunction("-", \&SimpleFunctions::minus);
  $this->setFunction("/", \&SimpleFunctions::divide);
  $this->setFunction("*", \&SimpleFunctions::multiplicate);
  $this->setFunction("^", \&SimpleFunctions::potentiate);
  $this->setFunction("cot", \&TrigonometricFunctions::cotangent);
  $this->setFunction("tan", \&TrigonometricFunctions::tangent);
  $this->setFunction("cos", \&TrigonometricFunctions::cosine);
  $this->setFunction("sin", \&TrigonometricFunctions::sine);
  $this->setFunction("sqrt", \&ComplexFunctions::square_root);
  $this->setFunction("ln", \&ComplexFunctions::natural_logarithm);
  $this->setFunction("logn", \&ComplexFunctions::logarithm);
  $this->setFunction("neg", \&SimpleFunctions::negate);
  $this->setFunction("=", \&SimpleFunctions::assign);
  $this->setFunction("sum", \&SimpleFunctions::sum);
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

sub getVariable {
  my ($this, $key) = @_;

  return ${$this->variables}{$key};
}

sub setVariable {
  my ($this, $key, $value) = @_;

  ${$this->variables}{$key} = $value;
}

sub getFunction {
  my ($this, $key) = @_;

  return ${$this->functions}{$key};
}

sub setFunction {
  my ($this, $key, $ref) = @_;

  ${$this->functions}{$key} = $ref;
}

sub evaluate {
  my ($this, $treeRef) = @_;
  my $tree = $$treeRef;
  my $val = $tree->value();

  if ($tree->size() == 1) {
    if ($val =~ /[a-zA-Z]+/) {
      return $this->getVariable($val);
    } else {
      return $val;
    }
  } else {
    my $func = $this->getFunction($tree->value());

    my @args = map { \$_ } $tree->children();

    return &{$func}(\$this, @args);
  }
}

1;
