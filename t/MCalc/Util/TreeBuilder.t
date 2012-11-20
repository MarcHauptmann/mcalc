#!/usr/bin/perl

use Test::More;
use Tree;

BEGIN {
  use_ok("MCalc::Util::TreeBuilder");
}

subtest "a tree with one node can be built" => sub {
  my $stringTree = <<EOF;
         1
EOF

  my $expectedTree = Tree->new("1");
  my $tree = tree($stringTree);

  is_deeply($tree, $expectedTree, "tree matches");
};

subtest "a tree with one child can be built" => sub {
  my $expectedTree = Tree->new("1");
  $expectedTree->add_child(Tree->new("2"));

  my $tree = tree(<<EOF
         1
         |
         2
EOF
                 );

  is_deeply($tree, $expectedTree, "tree matches");
};

subtest "a tree with two child nodes can be built" => sub {
  my $expectedTree = Tree->new("1");
  $expectedTree->add_child(Tree->new("2"));
  $expectedTree->add_child(Tree->new("3"));

  my $tree = tree(<<EOF
     1
    / \\
   2   3
EOF
                 );

  is_deeply($tree, $expectedTree, "tree matches");
};

subtest "a complex tree with subtree can be built" => sub {
  my $expectedTree = Tree->new("1");
  my $subtree = Tree->new("2");
  $subtree->add_child(Tree->new("4"));
  $subtree->add_child(Tree->new("5"));
  $expectedTree->add_child($subtree);
  $expectedTree->add_child(Tree->new("3"));

  my $tree = tree(<<EOF
         1
        / \\
       2   3
      / \\
     4   5
EOF
                 );

  is_deeply($tree, $expectedTree, "tree matches");
};



done_testing();
