package parser;

use Exporter;
use Tree;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(parse parseTree);
our @EXPORT = qw(parse parseTree);

sub parse {
    my $input = @_[0];

    return $input =~ /^\d+\.?\d*([\+\-\*\/]\d+\.?\d*)*$/;
}

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


