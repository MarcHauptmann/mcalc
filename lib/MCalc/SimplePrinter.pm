package MCalc::SimplePrinter;

use Moose;
use MCalc::Language;

with "MCalc::Printer";

sub to_string {
  my ($this, $tree, $weight, $last, $lastIndex) = @_;

  my $op = $tree->value();

  if ($tree->size() == 1) {
    return $op;
  } else {
    my $opWeight = operator_weight($op);

    my $index = 0;

    my @args = map { $this->to_string($_, $opWeight, $op, $index++) } $tree->children();

    if (is_operator($op)) {
      my $str = sprintf "%s %s %s", $args[0], $op, $args[1];

      if (defined($weight) && $weight > $opWeight) {
        $str = sprintf "(%s)", $str;
      }

      return $str;
    } elsif ($op eq "neg") {
      my $string = sprintf "-%s", $args[0];

      if ($this->needs_braces($last, $lastIndex)) {
        return sprintf "(%s)", $string;
      } else {
        return $string;
      }
    } else {
      my $str = sprintf "%s(%s)", $op, join(", ", @args);

      return $str;
    }
  }
}

sub needs_braces {
  my ($this, $lastOperator, $myIndex) = @_;

  return defined($lastOperator) && is_operator($lastOperator) && $myIndex > 0;
}

1;
