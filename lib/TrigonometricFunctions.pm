package TrigonometricFunctions;

use Math::Trig;

sub cosine {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);

  return cos($v1);
}

sub sine {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);

  return sin($v1);
}

sub tangent {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);

  return tan($v1);
}

sub cotangent {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);

  return cot($v1);
}

1;
