=head1 NAME

evaluator

=head1 DESCRIPTION

Wertet die Ausdrücke aus

=over 12

=cut

package evaluator;

use Switch;
use List::MoreUtils qw(firstidx);
use Exporter;
use Tree;
use Math::Trig;
use Math::Complex;

our @ISA=qw(Exporter);
our @EXPORT_OK=qw(evaluate);
our @EXPORT = qw(evaluate);

=item evaluate

Macht eine Auswertung

=cut

%functions =  (
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
	       }
	      );

sub evaluate {
  my $tree = ${$_[0]};
  my @values = ();

  if($tree->size() == 1) {
    return $tree->value();
  } else {
    my $func = $functions{$tree->value()};

    @args = map { evaluate(\$_) } $tree->children();

    return &{$func}(@args);
  }
}
