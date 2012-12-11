package MCalc::PrettyPrinter;

use Moose;
use MCalc::SimplePrinter;
use MCalc::Language;
use List::Util qw(max);
use POSIX;
use Encode;

with "MCalc::Printer";

has "simplePrinter" => (isa => "Ref",
                        is => "ro",
                        default => sub { MCalc::SimplePrinter->new() });

sub to_string {
  my ($this, $tree, $weight) = @_;

  my $result;

  if ($tree->value() eq "/") {
    $result = $this->handle_division($tree, $weight);
  } elsif ($tree->value() eq "^") {
    $result = $this->handle_power($tree);
  } elsif ($tree->value() eq "neg") {
    $result = $this->handle_negation($tree);
  } elsif (is_operator($tree->value())) {
    my $operator = $tree->value();

    my $string = $this->handle_operator($tree);

    if (defined($weight) && $weight > operator_weight($operator)) {
      $string = brace($string);
    }

    $result = $string;
  } elsif ($tree->value() eq "sqrt") {
    $result = $this->handle_sqrt($tree);
  } else {
    $result = $this->simplePrinter->to_string($tree);
  }

  return removeTrailingSpaces($result);
}

sub brace {
  my ($string, $padding) = @_;

  if (not(defined($padding))) {
    $padding = 1;
  }

  my $lineCount = count_lines($string);

  if ($lineCount == 1) {
    return "(".str(" ", $padding).$string.str(" ", $padding).")";
  } else {
    my $lbrace = createLeftBrace($lineCount);
    my $rbrace = offset(createRightBrace($lineCount), $padding);

    return append($lbrace, offset(justify($string), $padding), $rbrace);
  }
}

sub createRightBrace {
  my ($height) = @_;

  my $brace = "";

  for (my $i = 0; $i<$height; $i++) {
    if ($i == 0) {
      $brace .= "\n⎞";
    } elsif ($i == $height - 1) {
      $brace .= "\n⎠";
    } else {
      $brace .= "\n⎟";
    }
  }

  return substr($brace, 1);
}

sub createLeftBrace {
  my ($height) = @_;

  my $brace = "";

  for (my $i = 0; $i<$height; $i++) {
    if ($i == 0) {
      $brace .= "\n⎛";
    } elsif ($i == $height - 1) {
      $brace .= "\n⎝";
    } else {
      $brace .= "\n⎜";
    }
  }

  return substr($brace, 1);
}

sub handle_negation {
  my ($this, $tree) = @_;

  my $expression = $this->to_string($tree->children(0));
  my $negation = justify_height("-", count_lines($expression));

  return append($negation, $expression);
}

sub handle_power {
  my ($this, $tree) = @_;

  my $exponent = $this->to_string($tree->children(1));
  my $base = justify($this->to_string($tree->children(0), operator_weight("^")));

  my $width = max_line_length($base);
  my $height = count_lines($exponent);

  return append(whitespaces($width, $height), $exponent)."\n".$base;
}

sub whitespaces {
  my ($width, $height) = @_;

  my $space = str(" ", $width);
  $space = justify_height($space, $height);
  $space = justify($space);

  return $space;
}

sub handle_sqrt {
  my ($this, $tree) = @_;

  my $radiant = $this->to_string($tree->children(0));
  my $width = max_line_length($radiant);

  my $string = " ┌".str("─", $width + 2)."\n";

  my @lines = split(/\n/, $radiant);

  for (my $i = 1; $i <= scalar(@lines); $i++) {
    if ($i == scalar(@lines)) {
      $string .= "╲│ ".$lines[$i-1];
    } else {
      $string .= " │ ".$lines[$i-1]."\n";
    }
  }

  return $string;
}

sub handle_division {
  my ($this, $tree, $parent_weight) = @_;

  my $nominator = $this->to_string($tree->children(0));
  my $denominator = $this->to_string($tree->children(1));

  my $l = max_line_length($nominator, $denominator);

  my $string = offset($nominator, ($l - max_line_length($nominator))/2 + 1);

  $string .= sprintf "\n%s\n", str("‒", $l + 2);
  $string .= offset($denominator, ($l - max_line_length($denominator))/2 + 1);

  if (defined($parent_weight) && $parent_weight > operator_weight("/")) {
    return brace($string);
  } else {
    return $string;
  }
}

sub handle_operator {
  my ($this, $tree, $parent_weight) = @_;

  my $weight = operator_weight($tree->value());
  my $lhs = justify($this->to_string($tree->children(0), $weight));
  my $rhs = justify($this->to_string($tree->children(1), $weight));

  if (count_lines($lhs) < count_lines($rhs)) {
    $lhs = justify_height($lhs, count_lines($rhs));
  } elsif (count_lines($lhs) > count_lines($rhs)) {
    $rhs = justify_height($rhs, count_lines($lhs));
  }

  my $height = count_lines($lhs);
  my $opString = operator($tree->value(), $height);

  if (isNegated($tree->children(1))) {
    return append($lhs, $opString, brace($rhs, 0));
  } else {
    return append($lhs, $opString, $rhs);
  }
}

sub operator {
  my ($operator, $height) = @_;

  my $opString = "";

  for (my $i=0; $i<$height; $i++) {
    $opString .= "\n";

    if ($i == POSIX::floor($height / 2)) {
      $opString .= " ".$operator." ";
    } else {
      $opString .= " ";
    }
  }

  return justify(substr($opString, 1));
}

sub isNegated {
  my ($tree) = @_;

  return $tree->value() eq "neg";
}

sub count_lines {
  my ($string) = @_;

  return scalar(split(/\n/, $string));
}

sub append {
  my @args = @_;

  if (scalar(@args) == 2) {
    my ($lhs, $rhs) = @args;

    my @llines = split(/\n/, $lhs);
    my @rlines = split(/\n/, $rhs);

    if (scalar(@llines) != scalar(@rlines)) {
      die sprintf "line count is not equal: lhs = '%s'; rhs = '%s'\n", $lhs, $rhs;
    }

    my $result = "";

    for (my $i = 0; $i<scalar(@llines); $i++) {
      $result .= "\n".$llines[$i].$rlines[$i];
    }

    return substr($result, 1);
  } else {
    my $first = shift @args;

    return append($first, append(@args));
  }
}

sub justify_height {
  my ($string, $count) = @_;

  my @lines = split(/\n/, $string);

  while (scalar(@lines) < $count) {
    if (scalar(@lines) % 2 == 0) {
      push @lines, " ";
    } else {
      @lines = (" ", @lines);
    }
  }

  $string = "";

  foreach my $line (@lines) {
    $string .= "\n".$line;
  }

  return substr($string, 1);
}

sub justify {
  my ($lines) = @_;

  my $length = max_line_length($lines);
  my $string = "";

  foreach my $line (split(/\n/, $lines)) {
    my $l = length(Encode::decode_utf8($line));

    $string .= "\n".$line.str(" ", $length - $l);
  }

  return substr($string, 1);
}

# puts n whitespaces in front of every line of a given string
sub offset {
  my ($lines, $offset) = @_;

  my $string = "";

  foreach my $line (split(/\n+/, $lines)) {
    $string .= "\n".str(" ", $offset).$line;
  }

  return substr $string, 1;
}

# returns the maximum line length of a given string
sub max_line_length {
  my (@strings) = @_;

  my @lines = map { split(/\n/, $_) } @strings;

  return max( map { length(Encode::decode_utf8($_)) } @lines );
}

# repeats a given string n-times
sub str {
  my ($str, $times) = @_;

  my $string = "";

  for (my $i = 0; $i < $times; $i++) {
    $string .= $str;
  }

  return $string;
}

sub removeTrailingSpaces {
  my ($string) = @_;

  $string =~ s/( *\n)/\n/g;
  $string =~ s/( *$)//g;

  return $string;
}

1;
