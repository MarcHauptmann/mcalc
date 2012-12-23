package MCalc::Functions::Multiplication;

use Moose;

with "MCalc::Functions::ArithmeticFunction";

sub BUILDARGS {
  return { sign => "*" };
}

sub doCalculation {
  my ($this, $a, $b) = @_;

  return $a * $b;
}

1;
