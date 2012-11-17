package MCalc::Functions::Assignment;

use Moose;
use MCalc::Functions::UserFunction;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $evaluatorRef, $contextRef, $lhsRef, $rhsRef) = @_;

  my $lhs = $$lhsRef;
  my $rhs = $$rhsRef;

  if ($lhs->size() == 1) {
    my $var = $lhs->value();
    my $value = $$evaluatorRef->evaluate($contextRef, $rhsRef);

    $$contextRef->setVariable($var, $value);

    return "$var = $value";
  } else {
    my $key = $lhs->value();
    my @args = map { $_->value() } $lhs->children();

    my $function = MCalc::Functions::UserFunction->new(arguments => \@args,
                                                       body => $rhs,
                                                       name => $key);

    $$contextRef->setFunction($key, $function);

    return "$key(".join(", ", @args).") defined";
  }
}

1;
