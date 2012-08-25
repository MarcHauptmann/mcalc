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
    $tree = $_[0];

    if($tree->size() == 1) {
	return $tree->value();
    } else {
	@children = $tree->children();

	switch($tree->value()) {
	    case("+") {
		return evaluate($children[0]) + evaluate($children[1]);
	    }
	    case("-") {
		return evaluate($children[0]) - evaluate($children[1]);
	    }
	    case("*") {
		return evaluate($children[0]) * evaluate($children[1]);
	    }
	    case("/") {
		return evaluate($children[0]) / evaluate($children[1]);
	    }
	}
    }
}
