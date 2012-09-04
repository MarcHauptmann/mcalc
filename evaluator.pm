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

our @ISA=qw(Exporter);
our @EXPORT_OK=qw(evaluate);
our @EXPORT = qw(evaluate);

=item evaluate

Macht eine Auswertung

=cut

sub evaluate {
  my $tree = $_[0];
  my @values = ();
  my @list = $tree->traverse($tree->PRE_ORDER);

  while(scalar(@list) > 0) {
    my $sym = pop @list;
    $sym = $sym->value();

    if($sym eq "+") {
      push @values, (pop @values) + (pop @values);
    } elsif($sym eq "-") {
      push @values, -((pop @values) - (pop @values));
    } elsif($sym eq "*") {
      push @values, (pop @values) * (pop @values);
    } elsif($sym eq "/") {
      push @values, 1/((pop @values) / (pop @values));
    } else {
      push @values, $sym;
    }
  }

  return pop @values;
}
