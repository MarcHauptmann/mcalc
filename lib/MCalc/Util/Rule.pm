package MCalc::Util::Rule;

use MCalc::Parser;
use Tree;
use Moose;
use Data::Dumper;
use MCalc::Util::Simplification;

has "lhs" => (isa => "Tree",
              is => "rw",
              writer => "setLhs",
              reader => "getLhs",
              default => sub { return Tree->new() } );

has "rhs" => (isa => "Tree",
              is => "rw",
              writer => "setRhs",
              reader => "getRhs",
              default => sub { return Tree->new() } );

has "description" => (isa => "Str",
                      is => "rw",
                      reader => "getDescription",
                      writer => "setDescription",
                      default => sub { return "no description" } );

sub BUILDARGS {
  my ($this, $expression, $description) = @_;

  my $parser = MCalc::Parser->new();
  my $equation = $parser->parse($expression);

  my %parameters = (lhs => $equation->children(0)->clone,
                    rhs => $equation->children(1)->clone);

  if (defined($description)) {
    $parameters{description} = $description;
  }

  return \%parameters;
}

sub matches {
  my ($this, $tree) = @_;

  my $lhs = $this->getLhs();

  return rule_matches($this->getLhs, $tree);
}

sub apply {
  my ($this, $tree) = @_;

  my $lhs = $this->getLhs();
  my $rhs = $this->getRhs();

  my %values = extract_values($lhs, $tree);

  # print $values{var}->value."\n";
  # print $rhs->value."\n";

  return substitute($rhs, %values);
}

1;
