package ComplexFunctions;

use Math::Complex;

sub square_root {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);

  return sqrt($v1);
}

sub natural_logarithm {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);

  return log($v1);
}

sub logarithm {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);
  my $v2 = $$evaluatorRef->evaluate($args[1]);

  return logn($v1, $v2);
}
