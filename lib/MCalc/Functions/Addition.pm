package MCalc::Functions::Addition;

use Moose;


with "MCalc::Functions::ArithmeticFunction";

sub BUILDARGS {
  return { sign => "+" };
}

sub doCalculation {
  my ($this, $v1, $v2) = @_;

  return $v1 + $v2;
}

1;
