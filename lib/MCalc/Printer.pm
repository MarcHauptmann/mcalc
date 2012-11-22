package MCalc::Printer;

use Moose;
use Exporter;
use MCalc::Language;

sub to_string {
  my ($this, $tree, $weight) = @_;

  my $op = $tree->value();

  if ($tree->size() == 1) {
    return $op;
  } else {
    my $opWeight = operator_weight($op);
    my @args = map { $this->to_string($_, $opWeight) } $tree->children();

    if (is_operator($op)) {
      my $str = sprintf "%s %s %s", $args[0], $op, $args[1];

      if(defined($weight) && $weight > $opWeight) {
	$str = sprintf "(%s)", $str;
      }

      return $str;
    } else {
      my $str = sprintf "%s(%s)", $op, join(", ", @args);

      return $str;
    }
  }
}

1;
