package MCalc::Functions::Assignment;

use Moose;
use MCalc::Language;
use Error::Simple;
use MCalc::Evaluator;
use MCalc::Functions::UserFunction;

with "MCalc::Evaluateable";

sub evaluate {
  my ($this, $contextRef, $lhsRef, $rhsRef) = @_;

  my $lhs = $$lhsRef;
  my $rhs = $$rhsRef;

  if ($lhs->size() == 1) {
    my $var = $lhs->value();
    my $value = evaluateTree($contextRef, $rhsRef);

    if (not($var =~ /[a-zA-Z]\w*+/)) {
      throw Error::Simple "variable name must be string";
    } else {
      $$contextRef->setVariable($var, $value);

      return "$var = $value";
    }
  } else {
    my $key = $lhs->value();
    my @args = map { $_->value() } $lhs->children();

    # validate function name
    if (not(is_identifier($key))) {
      throw Error::Simple "invalid function definition";
    }

    # validate arguments
    foreach my $child ($lhs->children) {
      if ($child->size() != 1) {
        throw Error::Simple "argument must be single variable";
      }
    }

    my $function = MCalc::Functions::UserFunction->new(arguments => \@args,
                                                       body => $rhs,
                                                       name => $key);

    $$contextRef->setFunction($key, $function);

    return "$key(".join(", ", @args).") defined";
  }
}

1;
