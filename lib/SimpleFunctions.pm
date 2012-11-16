package SimpleFunctions;

use strict;

sub plus {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);
  my $v2 = $$evaluatorRef->evaluate($args[1]);

  return $v1 + $v2;
}

sub minus {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);
  my $v2 = $$evaluatorRef->evaluate($args[1]);

  return $v1 - $v2;
}

sub divide {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);
  my $v2 = $$evaluatorRef->evaluate($args[1]);

  return $v1 / $v2;
}

sub multiplicate {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);
  my $v2 = $$evaluatorRef->evaluate($args[1]);

  return $v1 * $v2;
}

sub potentiate {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);
  my $v2 = $$evaluatorRef->evaluate($args[1]);

  return $v1 ** $v2;
}

sub negate {
  my ($evaluatorRef, @args) = @_;

  my $v1 = $$evaluatorRef->evaluate($args[0]);

  return -$v1;
}

sub assign {
  my ($evaluator, @args) = @_;

  my $var = ${$args[0]}->value();
  my $value = $$evaluator->evaluate($args[1]);

  $$evaluator->setVariable($var, $value);

  return "$var = $value";
}

sub sum {
  my ($evaluator, $exRef, $varRef, $fromRef, $toRef) = @_;

  my $var = $$varRef->value();
  my $from = $$evaluator->evaluate($fromRef);
  my $to = $$evaluator->evaluate($toRef);

  my $result = 0;

  my $oldVar = $$evaluator->getVariable($var);

  for (my $i=$from; $i<=$to; $i++) {
    $$evaluator->setVariable($var, $i);
    $result += $$evaluator->evaluate($exRef);
  }

  $$evaluator->setVariable($var, $oldVar);

  return $result;
}

1;