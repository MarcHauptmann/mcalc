package parser;

use Exporter;
use Tree;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(parse parseTree number addition top);
our @EXPORT = qw(parse parseTree number addition top);

sub consume {
  shift(@tokens);
}

sub getNext {
  return $tokens[0];
}

sub top {
  $size = scalar(@_);

  if($size > 0) {
    return $_[$size - 1];
  } else {
    die "Element erwartet";
  }
}

sub weight {
  if($_[0] eq "+" || $_[0] eq "-") {
    return 1;
  } elsif($_[0] eq "*" || $_[0] eq "/") {
    return 2;
  } else {
    return 0;
  }
}

sub isOp {
  return $tokens[0] =~ /\+|\-|\*|\//;
}

sub popOperator {
  my $node1 = pop @operands;
  my $node2 = pop @operands;
  my $operator = pop @operators;

  my $newNode = Tree->new($operator);
  $newNode->add_child($node2);
  $newNode->add_child($node1);

  push @operands, $newNode;
}

sub pushOperator {
  my $op = $_[0];

  while (weight(top(@operators)) > weight($op)) {
    popOperator();
  }

  push @operators, $op;
}

sub expect {
  my $sym = getNext();

  if ($sym eq $_[0]) {
    consume();
  } else { 
    die "erwartet: ".$sym;
  }
}

sub op {
  my $sym = getNext();

  if ($sym eq "+" || $sym eq "-" || $sym eq "*" || $sym eq "/") {
    pushOperator($sym);
    consume();
  } else {
    die "kein Operator: ".$sym;
  }
}

sub E {
  P();

  while (isOp()) {
    op();
    P();
  }

  while (top(@operators) ne ";") {
    popOperator();
  }
}

sub args {
  $argCount = 1;
  push @operands, ";";
  P();

  while(getNext() eq ",") {
    consume();
    P();
    $argCount++;
  }

  my $node = Tree->new(pop @operators);
  my @values = ();

  while(top(@operands) ne ";") {
    push @values, pop @operands
  }
  pop @operands;
  map { $node->add_child($_) } reverse @values;

  push @operands, $node;
}

sub P {
  my $sym = getNext();

  if ($sym =~ /\d+\.?\d?/) {
    $num = Tree->new($sym);
    push @operands, $num;
    consume();
  } elsif ($sym eq "(") {
    push @operators, ";";
    consume();
    E();
    expect(")");
    pop @operators;
  } elsif($sym =~ /[a-zA-Z]+/) {
    push @operators, $sym;
    consume();
    expect("(");
    args();
    expect(")");
  }else {
    die "unbekanntes Symbol: '".$sym."'";
  }
}


sub parse {
  our @operators = (";");
  our @operands = (";");

  my @tokens_plain = split(/([\(\)\+\-\*\/,])/, $_[0]);
  our @tokens = ();

  foreach $token (@tokens_plain) {
    if($token ne "") {
      push @tokens, $token;
    }
  }

  push @tokens, ";";

  E();
  expect(";");

  my $tree = pop @operands;

  return $tree;
}

