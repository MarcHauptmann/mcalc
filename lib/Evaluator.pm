package Evaluator;

use Moose;
use List::MoreUtils qw(firstidx);
use Exporter;
use Tree;
use Math::Trig;
use Math::Complex;

has "variables" => (is => "rw",
		    isa => "HashRef",
		    default => sub {
		      { "pi" => 3.1415 };
		    });

has "functions" => (is => "rw",
		    isa => "HashRef",
		    default => sub {
		      {
		       "+" => sub {
			 return $_[0] + $_[1];
		       },
		       "-" => sub {
			 return $_[0] - $_[1];
		       },
		       "/" => sub {
			 return $_[0] / $_[1];
		       },
		       "*" => sub {
			 return $_[0] * $_[1];
		       },
		       "^" => sub {
			 return $_[0] ** $_[1];
		       },
		       "cot" => sub {
			 return cot($_[0]);
		       },
		       "cos" => sub {
			 return cos($_[0]);
		       },
		       "sin" => sub {
			 return sin($_[0]);
		       },
		       "tan" => sub {
			 return tan($_[0]);
		       },
		       "sqrt" => sub {
			 return sqrt($_[0]);
		       },
		       "ln" => sub {
			 return log($_[0]);
		       },
		       "logn" => sub {
			 return logn($_[0], $_[1]);
		       },
		       "neg" => sub {
			 return -$_[0];
		       }
		     }
		    });

sub getCompletions {
  my $this = shift;
  my @values = ();

  foreach my $val (keys %{$this->variables}) {
    if($val =~ /^$_[0]/) {
      push @values, $val;
    }
  }

  foreach my $val (keys %{$this->functions}) {
    if($val =~ /^$_[0]/) {
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

  if($tree->size() == 1) {
    if($val =~ /[a-zA-Z]+/) {
      return $this->getVariable($val);
    } else {
      return $val;
    }
  } elsif($val eq "=") {
    my $var = $tree->children(0)->value();
    my $value = $this->evaluate(\$tree->children(1));

    $this->setVariable($var, $value);

    return "$var = $value";
  } else {
    my $func = ${$this->functions}{$tree->value()};

    my @args = map { $this->evaluate(\$_) } $tree->children();

    return &{$func}(@args);
  }
}

1;
