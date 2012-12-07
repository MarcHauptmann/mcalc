package MCalc::Language;

use Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(is_operator is_identifier operator_weight is_number is_keyword);

sub is_operator {
  my ($op) = @_;

  if ($op =~ /\+|\-|\*|\/|\^|=/) {
    return 1;
  } else {
    return 0;
  }
}

sub is_identifier {
  my ($identifier) = @_;

  if($identifier  =~ /[a-zA-Z]+/) {
    return 1;
  } else {
    return 0;
  }
}

sub is_number {
  if($_[0] =~ /\d+\.?\d*/) {
    return 1;
  } else {
    return 0;
  }
}

sub operator_weight {
  if ($_[0] eq "+" || $_[0] eq "-") {
    return 2;
  } elsif ($_[0] eq "*") {
    return 3;
  } elsif ($_[0] eq "/") {
    return 4;
  } elsif ($_[0] eq "^") {
    return 6;
  } elsif ($_[0] eq "neg") {
    return 5;
  } elsif ($_[0] eq "=") {
    return 1;
  } else {
    return 0;
  }
}

sub is_keyword {
  my ($word) = @_;

  return $word =~ /bye|exit|quit/;
}

1;
