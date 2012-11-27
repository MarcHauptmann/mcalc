#!/usr/bin/perl

use Test::More;
use Tree;

BEGIN {
  use_ok("MCalc::Util::TreeBuilder");
}

subtest "a tree with one node can be built" => sub {
  my $expectedTree = Tree->new("1");
  my $tree = tree(<<EOF
     1
EOF
                 );

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

subtest "a tree with long lines is accepted" => sub {
  my $expectedTree = Tree->new("1");
  $expectedTree->add_child(Tree->new("2"));
  $expectedTree->add_child(Tree->new("3"));

  my $tree = tree(<<EOF
         1
        / \\
       /   \\
      /     \\
     2       3
EOF
                 );

  is_deeply($tree, $expectedTree, "tree matches");
};

subtest "a complex tree with two subtrees can be built" => sub {
  my $expectedTree = Tree->new("1");
  my $subtree1 = Tree->new("2");
  $subtree1->add_child(Tree->new("4"));
  $subtree1->add_child(Tree->new("5"));
  my $subtree2 = Tree->new("3");
  $subtree2->add_child(Tree->new("6"));
  $subtree2->add_child(Tree->new("7"));
  $expectedTree->add_child($subtree1);
  $expectedTree->add_child($subtree2);

  my $tree = tree(<<EOF
          1
        /   \\
       2     3
      / \\  / \\
     4   5 6   7
EOF
                 );

  is_deeply($tree, $expectedTree, "tree matches");
};

subtest "a tree with subtree on the right side can be built" => sub {
  my $expectedTree = Tree->new("1");
  my $subtree = Tree->new("3");
  $subtree->add_child(Tree->new("4"));
  $subtree->add_child(Tree->new("5"));
  $expectedTree->add_child(Tree->new("2"));
  $expectedTree->add_child($subtree);

  my $tree = tree(<<EOF
           1
          / \\
         2   3
         ^  / \\
           4   5
EOF
                 );

  is_deeply($tree, $expectedTree, "tree matches");
};

subtest "a tree for sum function can be built" => sub {
  my $expectedTree = Tree->new("sum");
  $expectedTree->add_child(Tree->new("i"));
  $expectedTree->add_child(Tree->new("i"));
  $expectedTree->add_child(Tree->new("1"));
  $expectedTree->add_child(Tree->new("5"));

  my $tree = tree(<<EOF
          sum
        / | | \\
       i  i 1  5
EOF
                 );

  is_deeply($tree, $expectedTree, "tree matches");
};

subtest "tree with linear left side can be parsed" => sub {
  my $expectedTree = Tree->new("=");
  my $rightTree = Tree->new("+");
  $rightTree->add_child(Tree->new("x"));
  $rightTree->add_child(Tree->new("5"));
  my $leftTree = Tree->new("f");
  $leftTree->add_child(Tree->new("x"));
  $expectedTree->add_child($leftTree);
  $expectedTree->add_child($rightTree);

  my $tree = tree(<<EOF
           =
          / \\
         f   +
         |  / \\
         x x   5
EOF
                 );

  is_deeply($tree, $expectedTree, "tree matches");
};

done_testing();
