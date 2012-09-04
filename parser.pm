package parser;

use Exporter;
use Tree;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(parse parseTree number addition top);
our @EXPORT = qw(parse parseTree number addition top);

#sub parse {
#     my $input = @_[0];

#     return $input =~ /^\d+\.?\d*([\+\-\*\/]\d+\.?\d*)*$/;
# }

sub parseTree {
    my $input = @_[0];

    my @tokens = split(/([\+\-\*\/])/, $input);
    my $tree = Tree->new("");
    my $root = $tree;

    foreach $token (@tokens) {
	# Zahl erkannt
	if($token =~ /\d+\.?\d*/) {
	    # leerer Baum
	    if($tree->value() eq "") {
		$tree->set_value($token);
	    } 
	    # schon Elemente enthalten
	    else {
		my $node = Tree->new($token);
		
		$tree->add_child($node);
	    }
	}
	# Operator
	elsif($token =~ /[\+\-]/) {
	    if($root->size() >= 2) {
		my $temp = $root;

		$root = Tree->new($token);
		$root->add_child($temp);
		$tree = Tree->new("");
		$root->add_child($tree);
	    } else {
		# Wurzel austauschen und neuen Zweig beginnen
		my $node = Tree->new($tree->value());
		my $nextTree = Tree->new("");

		$tree->set_value($token);
		$tree->add_child($node);
		$tree->add_child($nextTree);
		$tree = $nextTree;	    
	    }
	} elsif($token =~ /[\*\/]/) {
	    # Wurzel austauschen und neuen Zweig beginnen
	    my $node = Tree->new($tree->value());
	    my $nextTree = Tree->new("");

	    $tree->set_value($token);
	    $tree->add_child($node);
	    $tree->add_child($nextTree);
	    $tree = $nextTree;
	}
    }

    return $root;
}



sub number {
    my $sym = shift(@{$_[0]});

    if($sym =~ /\d+\.?\d*/) {
	return Tree->new($sym);
    } else {
	print "error";
    }
}

sub addition {
    
    my @list = @{$_[0]};

    $num1 = number(\@list);
    $op = shift(@list);
    $num2 = number(\@list);

    $tree = Tree->new($op);
    $tree->add_child($num1);
    $tree->add_child($num2);

    return $tree;
}

###########################################################

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
  $newNode->add_child($node1);
  $newNode->add_child($node2);

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
  } else {
    die "unbekanntes Symbol: '".$sym."'";
  }
}


sub parse {
  my $str = join("_", split(/([\(\)\+\-\*\/])/, $_[0]));
  $str =~ s/_+/_/g;
  our @tokens = split(/_/, $str);
  push @tokens, ";";
  our @operators = (";");
  our @operands = (";");

  E();
  expect(";");

  my $tree = pop @operands;

  return $tree;
}

