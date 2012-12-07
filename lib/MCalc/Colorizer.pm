package MCalc::Colorizer;

use Moose;
use Term::ANSIColor;

has baceColors => (isa => "ArrayRef",
                   is => "rw",
                   reader => "getBraceColors",
                   writer => "setBraceColors",
		  default => sub { ["green", "yellow", "blue", "magenta", "cyan"] });

has functionStyle => (isa => "Str",
                      is => "rw",
                      reader => "getFunctionStyle",
                      writer => "setFunctionStyle",
                      default => sub { return "underline bold" } );

has unknownStyle => (isa => "Str",
                     is => "rw",
                     reader => "getUnknownStyle",
                     writer => "setUnknownStyle",
                     default => sub { "" });

has variableStyle => (isa => "Str",
                      is => "rw",
                      reader => "getVariableStyle",
                      writer => "setVariableStyle",
                      default => sub { "bold" });

has context => (isa => "MCalc::Context",
                is => "rw",
                reader => "getContext",
                writer => "setContext");

sub colorize {
  my ($this, $expression) = @_;

  my @tokens = split(/([\(\)\+\-\*\/,\^=])/, $expression);

  my $level = 0;
  my $output = "";

  foreach my $token (@tokens) {
    if ($token eq "(" && $level >= 0) {
      my $c = $this->getBraceColors()->[$level];
      $level++;

      $output .= colored $token, $c." bold";
    } elsif ($token eq ")" && $level >= 0) {
      $level--;
      my $c = $this->getBraceColors()->[$level];

      $output .= colored $token, $c." bold";
    } elsif ($token =~ /[a-zA-Z]+/) {
      if ($this->getContext->functionIsDefined($token)) {
        $output .= colored($token, $this->getFunctionStyle());
      } elsif ($this->getContext->variableIsDefined($token)) {
        $output .= colored($token, $this->getVariableStyle());
      } else {
        $output .= colored($token, $this->getUnknownStyle());
      }
    } else {
      $output .= $token;
    }
  }

  return $output;
}

1;

