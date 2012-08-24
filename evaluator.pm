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

our @ISA=qw(Exporter);
our @EXPORT_OK=qw(evaluate);
our @EXPORT = qw(evaluate);

=item evaluate

Macht eine Auswertung

=cut

sub evaluate {
    my $input = @_[0];
    
    @list = split(/([\+\-\*\/])/, $input);

    while(scalar(@list) >= 3) {
	my $index = (firstidx { $_ eq "*" || $_ eq "/"} @list) - 1;

	if($index < 0) {
	    $index = 0;
	}

	splice(@list, $index, 2, calculate(@list[$index + 1], 
					   @list[$index], 
					   @list[$index + 2]));
    }
    
    return @list[0];
}

=item calculate
    
Macht eine simple Berechnung. Der Operator kann dabei als String übergeben werden.

=cut

sub calculate {
    my $op = @_[0];
    my $result = @_[1];
    my $val = @_[2];

    switch($op) {
	case("+") {
	    $result += $val;
	}
	case("-") {
	    $result -= $val;
	}
	case("*") {
	    $result *= $val;
	}
	case("/") {
	    $result /= $val;
	}
    }

    return $result;
}

=back

=cut
