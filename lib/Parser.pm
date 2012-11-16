package Parser;

use Moose;
use Tree;

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

  if($size > 0) {
    return $_[$size - 1];
  } else {
    die "Element erwartet";
  }
}

sub weight {
  if($_[0] eq "+" || $_[0] eq "-") {
    return 1;
  } elsif($_[0] eq "*") {
    return 2;
  } elsif($_[0] eq "/") {
    return 3;
  } elsif($_[0] eq "^") {
    return 5;
  } elsif($_[0] eq "neg") {
    return 4;
  } else {
    return 0;
  }
}

sub popOperator {
  my $this = shift;

  my $node1 = pop @{$this->operands};
  my $node2 = pop @{$this->operands};
  my $operator = pop @{$this->operators};

  my $newNode = Tree->new($operator);
  $newNode->add_child($node2);
  $newNode->add_child($node1);

  push @{$this->operands}, $newNode;
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
    die "'$sym' erwartet";
  }
}

sub isOp {
  my $this = shift;

  return $this->getNext() =~ /\+|\-|\*|\/|\^/;
}

sub negation {
  my $this = shift;

  return $this->getNext() eq "-";
}

sub expression {
  my $this = shift;

  if($this->negation()) {
    $this->consume();
    push @{$this->operators}, "neg";
  }

  $this->term();

  while ($this->isOp()) {
    $this->pushOperator($this->getNext());
    $this->consume();

    $this->term();
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

  while($this->getNext() eq ",") {
    $this->consume();

    push @{$this->operators}, ";";
    $this->expression();
    pop @{$this->operators};
  }

  my $node = Tree->new(pop @{$this->operators});
  my @values = ();

  while(top(@{$this->operands}) ne ";") {
    push @values, pop @{$this->operands};
  }
  map { $node->add_child($_) } reverse @values;
  pop @{$this->operands};

  push @{$this->operands}, $node;
}

sub number() {
  my $this = shift;

  return $this->getNext() =~ /\d+\.?\d*/;
}

sub identifier() {
  my $this = shift;

  return $this->getNext() =~ /[a-zA-Z]+/;
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
  } elsif($this->identifier()) {
    $this->consume();
    if($this->getNext() eq "(") {
      $this->consume();

      push @{$this->operators}, $sym;
      $this->args();
      $this->expect(")");
    } else {
      push @{$this->operands}, Tree->new($sym);
    }
  }else {
    die "unbekanntes Symbol: '".$sym."'";
  }
}

sub parse {
  my ($this, $input) = @_;
  push @{$this->operators}, ";";
  push @{$this->operands}, ";";

  my @tokens_plain = split(/([\(\)\+\-\*\/,\^=])/, $input);

  foreach my $token (@tokens_plain) {
    if($token ne "") {
      push @{$this->tokens}, $token;
    }
  }

  push @{$this->tokens}, ";";

  # wenn Zuweisung
  if($this->identifier() && scalar(@{$this->tokens}) >= 2 && ${$this->tokens}[1] eq "=") {
    push @{$this->operands}, Tree->new($this->getNext());
    $this->consume();
    push @{$this->operators}, "=";
    $this->consume();
  }

  $this->expression();

  if($this->getNext() ne ";") {
    die "vorzeitiges Ende der Eingabe";
  }

  my $tree = pop @{$this->operands};

  pop @{$this->operands};
  pop @{$this->operators};

  return $tree;
}

1;
