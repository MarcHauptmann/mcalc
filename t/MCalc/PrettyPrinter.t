#!/usr/bin/perl

use Test::More;
use MCalc::Util::TreeBuilder;

BEGIN {
  use_ok("MCalc::PrettyPrinter");
}

subtest "numbers can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();

  my $result = $printer->to_string(Tree->new("3"));

  is($result, "3");
};

subtest "fraction can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
             /
            / \
           1   2
EOF

  my $expected = <<EOF;
 1
---
 2
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "fraction with sum can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
             /
            / \
           +   3
          / \
         1   2
EOF

  my $expected = <<EOF;
 1 + 2
-------
   3
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "double fraction can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
             /
            / \
           1   /
           ^  / \
             2   3
EOF

  my $expected = <<EOF;
  1
-----
  2
 ---
  3
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "sum of fractions can be printed" => sub {
    my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
               +
             /   \
           /       /
          / \     / \
         1   2   3   4
EOF

  my $expected = <<EOF;
 1     3
--- + ---
 2     4
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "square root can be printed" => sub {
    my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
         sqrt
          |
          2
EOF

  my $expected = <<'EOF';
  ---
\| 2
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "square root of fraction can be printed" => sub {
    my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
         sqrt
          |
          /
         / \
        1   2
EOF

  my $expected = <<'EOF';
  -----
 |  1
 | ---
\|  2
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "variable assignment can be printed" => sub {
    my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
          =
         / \
        a   /
        ^  / \
          1   2
EOF

  my $expected = <<'EOF';
     1
a = ---
     2
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "function assignment can be printed" => sub {
    my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
            =
          /   \
        f      /
       / \    / \
      x   y  x   y
EOF

  my $expected = <<'EOF';
           x
f(x, y) = ---
           y
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

done_testing();
