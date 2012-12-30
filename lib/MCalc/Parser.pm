package MCalc::Parser;

use Moose;
use Tree;
use Error;
use MCalc::Language;

has "operators" => (is => "rw",
                    isa => "ArrayRef",
                    default => sub { [] });
has "operands" => (is => "rw",
                   isa => "ArrayRef",
                   default => sub { [] });

has "tokens" => (is => "rw",
                 isa => "ArrayRef",
                 default => sub { [] });

sub consume {
  my $this = shift;

  shift(@{$this->tokens()});
}

sub getNext {
  my $this = shift;

  return ${$this->tokens()}[0];
}

sub top {
  my $size = scalar(@_);

  if ($size > 0) {
    return $_[$size - 1];
  } else {
    throw Error::Simple "element expected";
  }
}

sub weight {
  return operator_weight($_[0]);
}

sub popOperator {
  my $this = shift;

  my $operator = pop @{$this->operators};

  if ($operator ne "neg") {
    my $node1 = pop @{$this->operands};
    my $node2 = pop @{$this->operands};

    my $newNode = Tree->new($operator);
    $newNode->add_child($node2);
    $newNode->add_child($node1);

    push @{$this->operands}, $newNode;
  } else {
    my $node = pop @{$this->operands};
    my $newNode = Tree->new($operator);
    $newNode->add_child($node);

    push @{$this->operands}, $newNode;
  }
}

sub pushOperator {
  my $this = shift;
  my $op = $_[0];

  while (weight(top(@{$this->operators})) > weight($op)) {
    $this->popOperator();
  }

  push @{$this->operators}, $op;
}

sub expect {
  my ($this, $expected) = @_;
  my $sym = $this->getNext();

  if ($sym eq $expected) {
    $this->consume();
  } else {
    throw Error::Simple "'$sym' expected";
  }
}

sub isOp {
  my $this = shift;

  return is_operator($this->getNext());
}

sub negation {
  my $this = shift;

  return $this->getNext() eq "-";
}

sub expression {
  my $this = shift;

  if ($this->negation()) {
    $this->consume();
    push @{$this->operators}, "neg";
  }

  $this->term();

  while ($this->isOp()) {
    my $operator = $this->getNext();

    $this->pushOperator($this->getNext());
    $this->consume();

    if ($operator eq "=") {
      push @{$this->operators}, ";";
      $this->expression();
      pop @{$this->operators}
    } else {
      $this->term();
    }
  }

  while (top(@{$this->operators}) ne ";") {
    $this->popOperator();
  }
}

sub args {
  my $this = shift;

  push @{$this->operands}, ";";

  push @{$this->operators}, ";";
  $this->expression();
  pop @{$this->operators};

  while ($this->getNext() eq ",") {
    $this->consume();

    push @{$this->operators}, ";";
    $this->expression();
    pop @{$this->operators};
  }

  my $node = Tree->new(pop @{$this->operators});
  my @values = ();

  while (top(@{$this->operands}) ne ";") {
    push @values, pop @{$this->operands};
  }
  map { $node->add_child($_) } reverse @values;
  pop @{$this->operands};

  push @{$this->operands}, $node;
}

sub number {
  my $this = shift;

  return is_number($this->getNext());
}

sub identifier {
  my $this = shift;

  return is_identifier($this->getNext());
}

sub term {
  my $this = shift;
  my $sym = $this->getNext();

  if ($this->number()) {
    my $num = Tree->new($sym);
    push @{$this->operands}, $num;
    $this->consume();
  } elsif ($sym eq "(") {
    push @{$this->operators}, ";";
    $this->consume();
    $this->expression();
    $this->expect(")");
    pop @{$this->operators};
  } elsif ($this->identifier()) {
    $this->consume();

    if ($this->getNext() eq "(") {
      $this->consume();

      push @{$this->operators}, $sym;
      $this->args();
      $this->expect(")");
    } else {
      push @{$this->operands}, Tree->new($sym);
    }
  } else {
    throw Error::Simple "unknown symbol: '$sym'";
  }
}

sub varAssignment {
  my ($this) = @_;

  return $this->identifier()
    && scalar(@{$this->tokens}) >= 2
      && ${$this->tokens}[1] eq "=";
}

sub functionAssignment {
  my ($this) = @_;

  if ($this->identifier() && ${$this->tokens}[1] eq "(") {
    my $index = 2;

    while (${$this->tokens}[$index] =~ /[a-zA-Z]/ && ${$this->tokens}[$index + 1] eq ",") {
      $index += 2;
    }

    return ${$this->tokens}[$index] =~ /[a-zA-Z]/ && ${$this->tokens}[$index+1] eq ")"
      && ${$this->tokens}[$index+2] eq "=";
  } else {
    return 0;
  }
}

sub parse {
  my ($this, $input) = @_;

  # clear lists
  $this->operators([]);
  $this->operands([]);
  $this->tokens([]);

  push @{$this->operators}, ";";
  push @{$this->operands}, ";";

  my @tokens_plain = split(/([\(\)\+\-\*\/,\^=])/, $input);

  foreach my $token (@tokens_plain) {
    if ($token ne "") {
      push @{$this->tokens}, $token;
    }
  }

  push @{$this->tokens}, ";";

  $this->expression();

  if ($this->getNext() ne ";") {
    throw Error::Simple "unexpected end of input";
  }

  my $tree = pop @{$this->operands};

  pop @{$this->operands};
  pop @{$this->operators};

  return $tree;
}

1;
