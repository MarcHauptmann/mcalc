package MCalc::PrettyPrinter;

use Tree;
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

  return removeTrailingSpaces($this->handle_internal($tree, $weight));
}

sub handle_internal {
  my ($this, $tree, $weight) = @_;

  my $result;
  my $base = 0;

  if ($tree->value() eq "/") {
    ($result, $base) = $this->handle_division($tree, $weight);
  } elsif ($tree->value() eq "^") {
    ($result, $base) = $this->handle_power($tree);
  } elsif ($tree->value() eq "neg") {
    ($result, $base) = $this->handle_negation($tree);
  } elsif (is_operator($tree->value())) {
    my $operator = $tree->value();
    my $string;

    ($string, $base) = $this->handle_operator($tree);

    if (defined($weight) && $weight > operator_weight($operator)) {
      $string = brace($string);
    }

    $result = $string;
  } elsif ($tree->value() eq "sqrt") {
    ($result, $base) = $this->handle_sqrt($tree);
  } elsif (is_identifier($tree->value()) && $tree->size() > 1) {
    ($result, $base) = $this->handle_function_call($tree);
  } elsif (is_identifier($tree->value())) {
    ($result, $base) = $this->handle_variable($tree);
  } else {
    $result = $this->simplePrinter->to_string($tree);
  }

  if (wantarray()) {
    return (justify($result), $base);
  } else {
    return justify($result);
  }
}

sub handle_variable {
  my ($this, $tree) = @_;

  my $val = $tree->value();

  if ($val eq "pi") {
    return ("π", 0);
  } else {
    return ($val, 0);
  }
}

sub handle_nary_function {
  my ($this, $tree, $symbol) = @_;

  my $lowerTree = Tree->new("=");
  $lowerTree->add_child($tree->children(1)->clone);
  $lowerTree->add_child($tree->children(2)->clone);
  my ($lower, $lowerBase) = $this->handle_internal($lowerTree);

  my ($upper, $upperBase) = $this->handle_internal($tree->children(3));

  my $l = max_line_length($upper, $lower);

  my $leftStr = offset($upper, ($l - max_line_length($upper))/2)."\n"
    .offset($symbol, $l/2-1)."\n".offset($lower, ($l - max_line_length($lower))/2);
  my $sumBase = count_lines($upper);

  my ($rightStr, $rightBase) = $this->handle_internal($tree->children(0));

  my ($sumStr, $right, $base) = equalize($leftStr, $rightStr, $sumBase, $rightBase);

  return (append($sumStr, offset($right, 1)), $base);
}

sub handle_function_call {
  my ($this, $tree) = @_;

  if ($tree->value eq "sum") {
    return $this->handle_nary_function($tree, "∑");
  } elsif ($tree->value eq "product") {
    return $this->handle_nary_function($tree, "∏");
  } else {
    my $callStr = "";
    my $callBase = 0;

    my $count = 0;

    foreach my $arg ($tree->children()) {
      my ($result, $base) = $this->handle_internal($arg);

      if ($count == 0) {
        $callStr = $result;
        $callBase = $base;
      } else {
        ($callStr, $result, $callBase) = equalize($callStr, $result, $callBase, $base);

        my $comma = operator(",", count_lines($result), $callBase);

        $callStr = append($callStr, $comma, $result);
      }

      $count++;
    }

    my $funcName = operator($tree->value(), count_lines($callStr), $callBase, 0);

    return (append($funcName, offset(brace($callStr), 1)), $callBase);
  }
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

  my ($expression, $base) = $this->handle_internal($tree->children(0));
  my $negation = operator("-", count_lines($expression), $base, 0);

  return append($negation, $expression), $base;
}

sub handle_power {
  my ($this, $tree) = @_;

  my $exponent = $this->handle_internal($tree->children(1));
  my ($base, $bbase) = $this->handle_internal($tree->children(0), operator_weight("^"));

  my $width = max_line_length($base);

  my $powerBase = $bbase + count_lines($exponent);

  return (offset($exponent, $width)."\n".$base, $powerBase);
}

sub handle_sqrt {
  my ($this, $tree) = @_;

  my ($radiant, $base) = $this->handle_internal($tree->children(0));
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

  return ($string, $base+1);
}

sub handle_division {
  my ($this, $tree, $parent_weight) = @_;

  my $nominator = $this->handle_internal($tree->children(0));
  my $denominator = $this->handle_internal($tree->children(1));

  my $l = max_line_length($nominator, $denominator);

  my $string = offset($nominator, ($l - max_line_length($nominator))/2 + 1);

  $string .= sprintf "\n%s\n", str("‒", $l + 2);
  $string .= offset($denominator, ($l - max_line_length($denominator))/2 + 1);

  my $base = count_lines($nominator);

  if (defined($parent_weight) && $parent_weight > operator_weight("/")) {
    return (brace($string), $base);
  } else {
    return ($string, $base);
  }
}

sub handle_operator {
  my ($this, $tree, $parent_weight) = @_;

  my $weight = operator_weight($tree->value());
  my ($lhs, $lbase) = $this->handle_internal($tree->children(0), $weight);
  my ($rhs, $rbase) = $this->handle_internal($tree->children(1), $weight);

  my $base;

  ($lhs, $rhs, $base) = equalize($lhs, $rhs, $lbase, $rbase);

  # braces for substraction of complex expressions
  if($tree->value eq "-" && isSum($tree->children(1))) {
    $rhs = brace($rhs);
  }

  my $height = count_lines($lhs);
  my $opString = operator($tree->value(), $height, $base);

  if (isNegated($tree->children(1))) {
    return (append(justify($lhs), $opString, brace(justify($rhs), 0)), $base);
  } else {
    return (append(justify($lhs), $opString, justify($rhs)), $base);
  }
}

sub isSum {
  my ($tree) = @_;

  return $tree->value() eq "+" || $tree->value() eq "-";
}

sub equalize {
  my ($lhs, $rhs, $lbase, $rbase) = @_;

  while ($lbase > $rbase) {
    $rbase++;
    $rhs = " \n".$rhs;
  }

  while ($lbase < $rbase) {
    $lbase++;
    $lhs = " \n".$lhs;
  }

  while (count_lines($rhs) < count_lines($lhs)) {
    $rhs = $rhs."\n ";
  }

  while (count_lines($rhs) > count_lines($lhs)) {
    $lhs = $lhs."\n ";
  }

  # lbase and rbase are equal now
  return (justify($lhs), justify($rhs), $lbase);
}

sub operator {
  my ($operator, $height, $base, $padding) = @_;

  if (not(defined($padding))) {
    $padding = 1;
  }

  my $opString = "";

  for (my $i=0; $i<$height; $i++) {
    $opString .= "\n";

    if ($i == $base) {
      $opString .= str(" ", $padding).$operator.str(" ", $padding);
    } else {
      $opString .= str(" ", $padding)." ".str(" ", $padding);
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
