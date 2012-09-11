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
  } elsif($_[0] eq "^") {
    return 3;
  } else {
    return 0;
  }
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
    die "'$sym' erwartet";
  }
}

sub isOp {
  return getNext() =~ /\+|\-|\*|\/|\^/;
}

sub expression {
  term();

  while (isOp()) {
    pushOperator(getNext());
    consume();

    term();
  }

  while (top(@operators) ne ";") {
    popOperator();
  }
}

sub args {
  my $numArgs = 1;

  push @operators, ";";
  expression();
  pop @operators;

  while(getNext() eq ",") {
    consume();

    push @operators, ";";
    expression();
    pop @operators;

    $numArgs++;
  }

  my $node = Tree->new(pop @operators);
  my @values = ();

  for($i = 0; $i<$numArgs; $i++) {
    push @values, pop @operands
  }
  map { $node->add_child($_) } reverse @values;

  push @operands, $node;
}

sub number() {
  return getNext() =~ /\d+\.?\d?/;
}

sub identifier() {
  return getNext() =~ /[a-zA-Z]+/;
}

sub term {
  my $sym = getNext();

  if (number()) {
    $num = Tree->new($sym);
    push @operands, $num;
    consume();
  } elsif ($sym eq "(") {
    push @operators, ";";
    consume();
    expression();
    expect(")");
    pop @operators;
  } elsif(identifier()) {
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

  my @tokens_plain = split(/([\(\)\+\-\*\/,\^])/, $_[0]);
  our @tokens = ();

  foreach $token (@tokens_plain) {
    if($token ne "") {
      push @tokens, $token;
    }
  }

  push @tokens, ";";

  expression();
  expect(";");

  my $tree = pop @operands;

  return $tree;
}

