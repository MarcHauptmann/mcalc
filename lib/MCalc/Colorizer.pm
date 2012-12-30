package MCalc::Colorizer;

use Moose;
use Term::ANSIColor;
use MCalc::Language;

has baceStyle => (isa => "ArrayRef",
                   is => "rw",
                   reader => "getBraceStyles",
                   writer => "setBraceStyles",
                   default => sub { ["bold green", "bold yellow", "bold blue", "bold cyan"] });

has functionStyle => (isa => "Str",
                      is => "rw",
                      reader => "getFunctionStyle",
                      writer => "setFunctionStyle",
                      default => sub { return "underline bold" } );

has unknownStyle => (isa => "Str",
                     is => "rw",
                     reader => "getUnknownStyle",
                     writer => "setUnknownStyle",
                     default => sub { "bright_white" });

has variableStyle => (isa => "Str",
                      is => "rw",
                      reader => "getVariableStyle",
                      writer => "setVariableStyle",
                      default => sub { "bold" });

has keywordStyle => (isa => "Str",
                     is => "rw",
                     reader => "getKeywordStyle",
                     writer => "setKeywordStyle",
                     default => sub { "bold blue" });

has braceHighlightStyles => (isa => "ArrayRef",
                             is => "rw",
                             reader => "getBraceHighlightStyles",
                             writer => "setBraceHighlightStyles",
                             default => sub { ["bold green on_bright_magenta",
                                               "bold yellow on_bright_magenta",
                                               "bold blue on_bright_magenta",
                                               "bold cyan on_bright_magenta",] });

has context => (isa => "MCalc::Context",
                is => "rw",
                reader => "getContext",
                writer => "setContext");

sub colorize {
  my ($this, $expression, $cursor) = @_;

  my @tokens = split(/([\(\)\+\-\*\/,\^=])/, $expression);

  my $level = 0;
  my $output = "";
  my $pos = 0;
  my $highlightLevel = -1;

  if (defined($cursor)) {
    $highlightLevel = $this->_determineBraceLevel($expression, $cursor);
  }

  foreach my $token (@tokens) {
    # handle opening brace
    if ($token eq "(" && $level >= 0) {
      my $c;

      if ($level == $highlightLevel) {
        $c = $this->getBraceHighlightStyle($level);
      } else {
        $c = $this->getBraceStyle($level);
      }

      $level++;

      $output .= colored($token, $c);
    }
    # handle closing brace
    elsif ($token eq ")" && $level >= 0) {
      my $c;

      $level--;

      if ($level == $highlightLevel) {
        $c = $this->getBraceHighlightStyle($level);
      } else {
        $c = $this->getBraceStyle($level);
      }


      $output .= colored($token, $c);
    } elsif ($token =~ /[a-zA-Z]+/) {
      if ($this->getContext->functionIsDefined($token)) {
        $output .= colored($token, $this->getFunctionStyle());
      } elsif ($this->getContext->variableIsDefined($token)) {
        $output .= colored($token, $this->getVariableStyle());
      } elsif (is_keyword($token)) {
        $output .= colored($token, $this->getKeywordStyle());
      } else {
        $output .= colored($token, $this->getUnknownStyle());
      }
    } else {
      $output .= $token;
    }
  }

  return $output;
}

sub getBraceHighlightStyle {
  my ($this, $level) = @_;

  my @styles = @{$this->getBraceHighlightStyles()};
  my $numStyles = scalar(@styles);

  return $styles[$level % $numStyles];
}

sub getBraceStyle {
  my ($this, $level) = @_;

  my @styles = @{$this->getBraceStyles};
  my $numStyles = scalar(@styles);

  return $styles[$level % $numStyles];
}

sub _determineBraceLevel {
  my ($this, $string, $cursor) = @_;

  my @tokens = split(/([\(\)])/, $string);

  my $pos = 0;
  my $level = -1;

  foreach my $token (@tokens) {
    if ($token eq "(") {
      $level++;

      if ($pos == $cursor) {
        return $level;
      }
    } elsif ($token eq ")") {
      if ($pos == $cursor - 1) {
        return $level;
      }

      $level--;
    }

    $pos += length($token);
  }

  return -1;
}

1;

