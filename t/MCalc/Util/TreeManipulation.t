#!/usr/bin/perl

use Test::More;
use MCalc::Util::TreeBuilder;

BEGIN {
  use_ok("MCalc::Util::TreeManipulation");
}

subtest "addition is commutative" => sub {
  my $inputTree = <<'EOF';
      +
     / \
    2   3
EOF

  my $secondTree = <<'EOF';
      +
     / \
    3   2
EOF

  my @resultTrees = get_equal_trees(tree($inputTree));

  is(scalar(@resultTrees), 2, "size is 2");
  is_deeply(\@resultTrees, [tree($inputTree), tree($secondTree)]);
};

subtest "addition of three numbers has six permutations" => sub {
  my $inputTree = <<'EOF';
      +
     / \
    2   +
    ^  / \
      3   4
EOF

  my $secondTree = <<'EOF';
      +
     / \
    +   2
   / \  ^
  3   4
EOF

  my $thirdTree = <<'EOF';
      +
     / \
    +   2
   / \  ^
  4   3
EOF

  my @resultTrees = get_equal_trees(tree($inputTree));

  my $expectedPermutations = [tree($inputTree),
                              tree($secondTree)];

  is(scalar(@resultTrees), 2, "size is 2");
  is_deeply(\@resultTrees, $expectedPermutations);
};

done_testing();
