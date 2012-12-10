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

  if ($tree->value() eq "/") {
    return $this->handle_division($tree, $weight);
  } elsif ($tree->value() eq "^") {
    $this->handle_power($tree);
  } elsif ($tree->value() eq "neg") {
    $this->handle_negation($tree);
  } elsif (is_operator($tree->value())) {
    my $operator = $tree->value();

    my $result = $this->handle_operator($tree);

    if (defined($weight) && $weight > operator_weight($operator)) {
      $result = $this->brace($result);
    }

    return $result;
  } elsif ($tree->value() eq "sqrt") {
    return $this->handle_sqrt($tree);
  } else {
    return $this->simplePrinter->to_string($tree);
  }
}

sub brace {
  my ($this, $string) = @_;

  my $lineCount = $this->count_lines($string);

  if ($lineCount == 1) {
    return "( ".$string." )";
  } else {
    my $lbrace = "";
    my $rbrace = "";

    for (my $i = 0; $i<$lineCount; $i++) {
      if ($i == 0) {
        $lbrace .= "\n⎛ ";
        $rbrace .= "\n ⎞";
      } elsif ($i == $lineCount - 1) {
        $lbrace .= "\n⎝ ";
        $rbrace .= "\n ⎠";
      } else {
        $lbrace .= "\n⎜ ";
        $rbrace .= "\n ⎟";
      }
    }

    $lbrace = substr($lbrace, 1);
    $rbrace = substr($rbrace, 1);

    $string = $this->append($lbrace, $string);
    $string = $this->justify($string);
    $string = $this->append($string, $rbrace);

    return $string;
  }
}

sub handle_negation {
  my ($this, $tree) = @_;

  my $expression = $this->to_string($tree->children(0));
  my $negation = $this->justify_height("-", $this->count_lines($expression));

  return $this->append($negation, $expression);
}

sub handle_power {
  my ($this, $tree) = @_;

  my $exponent = $this->to_string($tree->children(1));
  my $base = $this->to_string($tree->children(0), operator_weight("^"));
  $base = $this->justify($base);

  my $width = $this->max_line_length($base);
  my $height = $this->count_lines($exponent);

  my $space = $this->str(" ", $width);
  $space = $this->justify_height($space, $height);
  $space = $this->justify($space);

  my $result = $this->append($space, $exponent)."\n".$base;

  return $result;
}

sub handle_sqrt {
  my ($this, $tree) = @_;

  my $radiant = $this->to_string($tree->children(0));
  my $width = $this->max_line_length($radiant);

  my $string = " ┌".$this->str("─", $width + 2)."\n";

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

  my $l = $this->max_line_length($nominator, $denominator);

  my $string = $this->offset($nominator, ($l - $this->max_line_length($nominator))/2 + 1);

  $string .= sprintf "\n%s\n", $this->str("‒", $l + 2);
  $string .= $this->offset($denominator, ($l - $this->max_line_length($denominator))/2 + 1);

  if (defined($parent_weight) && $parent_weight > operator_weight("/")) {
    return $this->brace($string);
  } else {
    return $string;
  }
}

sub handle_operator {
  my ($this, $tree, $parent_weight) = @_;

  my $weight = operator_weight($tree->value());
  my $lhs = $this->to_string($tree->children(0), $weight);
  my $rhs = $this->to_string($tree->children(1), $weight);

  if ($this->count_lines($lhs) < $this->count_lines($rhs)) {
    $lhs = $this->justify_height($lhs, $this->count_lines($rhs));
  } elsif ($this->count_lines($lhs) > $this->count_lines($rhs)) {
    $rhs = $this->justify_height($rhs, $this->count_lines($lhs));
  }

  $lhs = $this->justify($lhs);

  my $opString = "";
  my $lineCount = $this->count_lines($lhs);

  for (my $i=0; $i<$lineCount; $i++) {
    $opString .= "\n";

    if ($i == POSIX::floor($lineCount / 2)) {
      $opString .= " ".$tree->value()." ";
    } else {
      $opString .= " ";
    }
  }

  $opString = substr($opString, 1);

  my $result =  $this->append($lhs, $opString);
  $result = $this->justify($result);
  $result = $this->append($result, $rhs);

  return $result;
}

sub count_lines {
  my ($this, $string) = @_;

  return scalar(split(/\n/, $string));
}

sub append {
  my ($this, $lhs, $rhs) = @_;

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
}

sub justify_height {
  my ($this, $string, $count) = @_;

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
  my ($this, $lines) = @_;

  my $length = $this->max_line_length($lines);
  my $string = "";

  foreach my $line (split(/\n/, $lines)) {
    my $l = length(Encode::decode_utf8($line));

    $string .= "\n".$line.$this->str(" ", $length - $l);
  }

  return substr($string, 1);
}

sub offset {
  my ($this, $lines, $offset) = @_;

  my $string = "";

  foreach my $line (split(/\n+/, $lines)) {
    $string .= "\n".$this->str(" ", $offset).$line;
  }

  return substr $string, 1;
}

sub max_line_length {
  my ($this, @strings) = @_;

  my @lines = map { split(/\n/, $_) } @strings;

  return max( map { length(Encode::decode_utf8($_)) } @lines );
}

sub str {
  my ($this, $str, $times) = @_;

  my $string = "";

  for (my $i = 0; $i < $times; $i++) {
    $string .= $str;
  }

  return $string;
}

1;
