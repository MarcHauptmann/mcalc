#!/usr/bin/perl

use Test::More;
use Tree;

BEGIN {
  use_ok("MCalc::Util::TreeBuilder");
}

subtest "a simple Tree with one node can be built" => sub {
  my $expectedTree = Tree->new("1");

  my $tree = tree(1);

  is_deeply($tree, $expectedTree, "tree matches");
};

subtest "a tree with two child nodes can be build" => sub {
  my $expectedTree = Tree->new("+");
  $expectedTree->add_child(Tree->new("a"));
  $expectedTree->add_child(Tree->new(1));

  my $tree = tree("+", "a", undef, "1");

  is_deeply($tree, $expectedTree, "tree matches");
};

subtest "a complex tree can be built" => sub {
  my $expectedTree = Tree->new("sum");
  my $subtree = Tree->new("/");
  $subtree->add_child(Tree->new("1"));
  $subtree->add_child(Tree->new("n"));
  $expectedTree->add_child($subtree);
  $expectedTree->add_child(Tree->new("n"));
  $expectedTree->add_child(Tree->new(1));
  $expectedTree->add_child(Tree->new(100));

  my $tree = tree("sum", "/", "1", undef, "n", undef, undef, "n", undef, 1, undef, 100);

  is_deeply($tree, $expectedTree, "tree matches");
};

done_testing();
