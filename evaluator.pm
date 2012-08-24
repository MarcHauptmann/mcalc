=head1 NAME

evaluator

=head1 DESCRIPTION

Wertet die Ausdrücke aus

=over 12

=cut

package evaluator;

use Switch;
use Exporter;

our @ISA=qw(Exporter);
our @EXPORT_OK=qw(evaluate);
our @EXPORT = qw(evaluate);

=item evaluate

Macht eine Auswertung

=cut

sub evaluate {
    my $input = @_[0];

    my $result = 0;
    my $op = "";

    foreach $val (split(/([\+\-\*\/])/, $input)) {
	# Operator
	if($val == "+" || $val == "-" || $val == "/" || $val == "*") {
	    $op = $val;
	} 
	# Zahl und schon eine im Speicher
	elsif($op ne "") {
	    $result = calculate($op, $result, $val);

	    $op = "";
	} 
	# erste Zahl
	else {
	    $result = $val;
	}
    }

    if($temp != 0 && $result == 0) {
	$result = $temp;
    }

    return $result;
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
