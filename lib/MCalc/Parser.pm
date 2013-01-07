package MCalc::Parser;

use Moose;
use Tree;
use Error;
use MCalc::Language;

use Readonly;

Readonly::Scalar my $TERMINATOR => qw{;};
Readonly::Scalar my $NEGATION => "neg";
Readonly::Scalar my $MINUS => q{-};
Readonly::Scalar my $PLUS => q{+};
Readonly::Scalar my $TIMES => q{*};
Readonly::Scalar my $DIVISION => q{/};
Readonly::Scalar my $POWER => q{^};
Readonly::Scalar my $EQUAL => q{=};
Readonly::Scalar my $COMMA => ",";
Readonly::Scalar my $OPENING_BRACE => "(";
Readonly::Scalar my $CLOSING_BRACE => ")";

has operators => (is => "rw",
									isa => "ArrayRef",
									default => sub { [] });

has operands => (is => "rw",
								 isa => "ArrayRef",
								 default => sub { [] });

has tokens => (is => "rw",
							 isa => "ArrayRef",
							 default => sub { [] });

sub consume {
	my ($this) = @_;

	shift(@{$this->tokens()});

	return;
}

sub getNext {
	my ($this) = @_;

	return ${$this->tokens()}[0];
}

sub top {
	my (@args) = @_;

	my $size = scalar(@args);

	if ($size > 0) {
		return $args[$size - 1];
	} else {
		throw Error::Simple "element expected";
	}
}

sub weight {
	my ($operator) = @_;

	return operator_weight($operator);
}

sub popOperator {
	my $this = shift;

	my $operator = pop @{$this->operators};

	if ($operator ne $NEGATION) {
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

	return;
}

sub pushOperator {
	my ($this, $op) = @_;

	while (weight(top(@{$this->operators})) > weight($op) 
		|| (top(@{$this->operators}) eq $MINUS && ($op eq $MINUS || $op eq $PLUS))) {
		$this->popOperator();
	}

	push @{$this->operators}, $op;

	return;
}

sub expect {
	my ($this, $expected) = @_;
	my $sym = $this->getNext();

	if ($sym eq $expected) {
		$this->consume();

		return;
	} else {
		throw Error::Simple "'$sym' expected";
	}
}

sub isOp {
	my $this = shift;

	return is_operator($this->getNext());
}

# negation = -
sub negation {
	my $this = shift;

	return $this->getNext() eq $MINUS;
}

# expression = [negation] term ((operator term) | (= expression))*
sub expression {
	my $this = shift;

	if ($this->negation()) {
		$this->consume();
		push @{$this->operators}, $NEGATION;
	}

	$this->term();

	while ($this->isOp()) {
		my $operator = $this->getNext();

		$this->pushOperator($this->getNext());
		$this->consume();

		if ($operator eq $EQUAL) {
			push @{$this->operators}, $TERMINATOR;
			$this->expression();
			pop @{$this->operators}
		} else {
			$this->term();
		}
	}

	while (top(@{$this->operators}) ne $TERMINATOR) {
		$this->popOperator();
	}

	return;
}

# args = expression ( ',' expression )*
sub args {
	my $this = shift;

	push @{$this->operands}, $TERMINATOR;

	push @{$this->operators}, $TERMINATOR;
	$this->expression();
	pop @{$this->operators};

	while ($this->getNext() eq $COMMA) {
		$this->consume();

		push @{$this->operators}, $TERMINATOR;
		$this->expression();
		pop @{$this->operators};
	}

	my $node = Tree->new(pop @{$this->operators});
	my @values = ();

	while (top(@{$this->operands}) ne $TERMINATOR) {
		push @values, pop @{$this->operands};
	}
	map { $node->add_child($_) } reverse @values;
	pop @{$this->operands};

	push @{$this->operands}, $node;

	return;
}

sub number {
	my $this = shift;

	return is_number($this->getNext());
}

sub identifier {
	my $this = shift;

	return is_identifier($this->getNext());
}

sub openingBrace {
	my ($this) = @_;

	return $this->getNext() eq $OPENING_BRACE
;
}

# term = number | '(' expression ')' | identifier [ '(' args ')' ]
sub term {
	my $this = shift;
	my $sym = $this->getNext();

	if ($this->number()) {
		my $num = Tree->new($sym);
		push @{$this->operands}, $num;
		$this->consume();
	} elsif ($this->openingBrace()) {
		push @{$this->operators}, $TERMINATOR;
		$this->consume();
		$this->expression();
		$this->expect($CLOSING_BRACE);
		pop @{$this->operators};
	} elsif ($this->identifier()) {
		$this->consume();

		# function call
		if ($this->openingBrace()) {
			$this->consume();

			push @{$this->operators}, $sym;
			$this->args();
			$this->expect($CLOSING_BRACE);
		} 
		# variable
		else {
			push @{$this->operands}, Tree->new($sym);
		}
	} else {
		throw Error::Simple "unknown symbol: '$sym'";
	}

	return;
}

sub varAssignment {
	my ($this) = @_;

	return $this->identifier()
		&& scalar(@{$this->tokens}) >= 2
			&& ${$this->tokens}[1] eq $EQUAL;
}

sub setInput {
	my ($this, $input) = @_;

	# wtf! why does $MINUS not work?
	my $regex = qr/([
		\-
		$OPENING_BRACE
		$CLOSING_BRACE
		$PLUS
		$TIMES
		$DIVISION
		$POWER
		$COMMA
		$EQUAL
	])/;

	my @tokens_plain = split($regex, $input);

	foreach my $token (@tokens_plain) {
		if (length($token) > 0) {
			push @{$this->tokens}, $token;
		}
	}

	push @{$this->tokens}, $TERMINATOR;

	return;
}

sub parse {
	my ($this, $input) = @_;

	# clear lists
	$this->operators([]);
	$this->operands([]);
	$this->tokens([]);

	push @{$this->operators}, $TERMINATOR;
	push @{$this->operands}, $TERMINATOR;

	$this->setInput($input);

	$this->expression();

	if ($this->getNext() ne $TERMINATOR) {
		throw Error::Simple "unexpected end of input";
	}

	my $tree = pop @{$this->operands};

	pop @{$this->operands};
	pop @{$this->operators};

	return $tree;
}

1;
