=head1 NAME

evaluator

=head1 DESCRIPTION

Wertet die Ausdrücke aus

=over 12

=cut

package evaluator;

use List::MoreUtils qw(firstidx);
use Exporter;
use Tree;
use Math::Trig;
use Math::Complex;

our @ISA=qw(Exporter);
our @EXPORT_OK=qw(evaluate getVariable getCompletions);
our @EXPORT = qw(evaluate getVariable getCompletions);

=item evaluate

Macht eine Auswertung

=cut

our %functions =  (
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
		  );

our %variables = (
		  "pi" => 3.1415
		 );

sub getCompletions {
  my @values = ();

  foreach $val (keys %variables) {
    if($val =~ /^$_[0]/) {
      push @values, $val;
    }
  }

  foreach $val (keys %functions) {
    if($val =~ /^$_[0]/) {
      push @values, $val;
    }
  }

  return @values;
}

sub getVariable {
  return $variables{$_[0]};
}

sub setVariable {
  $variables{$_[0]} = $_[1];
}

sub evaluate {
  my $tree = ${$_[0]};
  my $val = $tree->value();

  if($tree->size() == 1) {
    if($val =~ /[a-zA-Z]+/) {
      return getVariable($val);
    } else {
      return $val;
    }
  } elsif($val eq "=") {
    my $var = $tree->children(0)->value();
    my $value = evaluate(\$tree->children(1));

    setVariable($var, $value);

    return "$var = $value";
  } else {
    my $func = $functions{$tree->value()};

    @args = map { evaluate(\$_) } $tree->children();

    return &{$func}(@args);
  }
}
