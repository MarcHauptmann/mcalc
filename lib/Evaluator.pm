package Evaluator;

use Moose;
use Tree;
use Math::Complex;
use SimpleFunctions;
use TrigonometricFunctions;

has "variables" => (is => "rw",
                    isa => "HashRef",
                    default => sub {
                      {
                        "pi" => 3.1415;
                      }
                      ;
                    });

has "functions" => (is => "rw",
                    isa => "HashRef",
                    default => sub {
                      {("+" => \&SimpleFunctions::plus,
                        "-" => \&SimpleFunctions::minus,
                        "/" => \&SimpleFunctions::divide,
                        "*" => \&SimpleFunctions::multiplicate,
                        "^" => \&SimpleFunctions::potentiate,
                        "cot" => \&TrigonometricFunctions::cotangent,
                        "cos" => \&TrigonometricFunctions::cosine,
                        "sin" => \&TrigonometricFunctions::sine,
                        "tan" => \&TrigonometricFunctions::tangent,
                        "sqrt" => \&ComplexFunctions::square_root,
                        "ln" => \&ComplexFunctions::natural_logarithm,
                        "logn" => \&ComplexFunctions::logarithm,
                        "neg" => \&SimpleFunctions::negate,
                        "=" => \&SimpleFunctions::assign,
                        "sum" => \&SimpleFunctions::sum
                       )}
                    });

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
    my $func = ${$this->functions}{$tree->value()};

    my @args = map { \$_ } $tree->children();

    return &{$func}(\$this, @args);
  }
}

1;
