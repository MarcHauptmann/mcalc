package MCalc::Language;

use Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(is_operator is_identifier);

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

1;
