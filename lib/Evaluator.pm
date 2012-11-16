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
  $this->setVariable("e", exp(1));

  # Funktionen definieren
  $this->setFunction("+", \&SimpleFunctions::plus);
  $this->setFunction("-", \&SimpleFunctions::minus);
  $this->setFunction("/", \&SimpleFunctions::divide);
  $this->setFunction("*", \&SimpleFunctions::multiplicate);
  $this->setFunction("^", \&SimpleFunctions::potentiate);
  $this->setFunction("abs", \&SimpleFunctions::absolute);
  $this->setFunction("floor", \&SimpleFunctions::floor);
  $this->setFunction("ceil", \&SimpleFunctions::ceil);
  $this->setFunction("round", \&SimpleFunctions::round);
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
