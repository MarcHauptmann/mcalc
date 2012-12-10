package MCalc::PrettyPrinter;

use Moose;
use MCalc::SimplePrinter;
use MCalc::Language;
use List::Util qw(max);
use POSIX;

with "MCalc::Printer";

has "simplePrinter" => (isa => "Ref",
                        is => "ro",
                        default => sub { MCalc::SimplePrinter->new() });

sub to_string {
  my ($this, $tree) = @_;

  if ($tree->value() eq "/") {
    return $this->handle_division($tree);
  } elsif (is_operator($tree->value())) {
    return $this->handle_operator($tree);
  } elsif ($tree->value() eq "sqrt") {
    return $this->handle_sqrt($tree);
  } else {
    return $this->simplePrinter->to_string($tree);
  }
}

sub handle_sqrt {
  my ($this, $tree) = @_;

  my $radiant = $this->to_string($tree->children(0));
  my $width = $this->max_line_length($radiant);

  my $string = "  ".$this->str("-", $width + 2)."\n";

  my @lines = split(/\n/, $radiant);

  for (my $i = 1; $i <= scalar(@lines); $i++) {
    if ($i == scalar(@lines)) {
      $string .= "\\| ".$lines[$i-1];
    } else {
      $string .= " | ".$lines[$i-1]."\n";
    }
  }

  return $string;
}

sub handle_division {
  my ($this, $tree) = @_;

  my $nominator = $this->to_string($tree->children(0));
  my $denominator = $this->to_string($tree->children(1));

  my $l = $this->max_line_length($nominator, $denominator);

  my $string = $this->offset($nominator, ($l - $this->max_line_length($nominator))/2 + 1);

  $string .= sprintf "\n%s\n", $this->str("-", $l + 2);
  $string .= $this->offset($denominator, ($l - $this->max_line_length($denominator))/2 + 1);

  return $string;
}

sub handle_operator {
  my ($this, $tree) = @_;

  my $lhs = $this->to_string($tree->children(0));
  my $rhs = $this->to_string($tree->children(1));

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

sub justify {
  my ($this, $lines) = @_;

  my $length = $this->max_line_length($lines);
  my $string = "";

  foreach my $line (split(/\n/, $lines)) {
    my $l = length($line);

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

  return max( map { length($_) } @lines );
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
