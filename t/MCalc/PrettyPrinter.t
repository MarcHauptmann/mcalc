#!/usr/bin/perl

use Test::More;
use MCalc::Util::TreeBuilder;
use MCalc::Parser;

BEGIN {
  use_ok("MCalc::PrettyPrinter");
}

our $parser = MCalc::Parser->new();

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
‒‒‒
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
‒‒‒‒‒‒‒
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

  my $expected = <<'EOF';
  1
‒‒‒‒‒
  2
 ‒‒‒
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

  my $expected = <<'EOF';
 1     3
‒‒‒ + ‒‒‒
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
 ┌───
╲│ 2
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
 ┌─────
 │  1
 │ ‒‒‒
╲│  2
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
a = ‒‒‒
     2
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "braces can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
            *
          /   \
        3      +
        ^     / \
             x   y
EOF

  my $expected = <<'EOF';
3 * ( x + y )
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "braces in complex expressions can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
            *
          /   \
        3      +
        ^     / \
             /   y
            / \
           1   2
EOF

  my $expected = <<'EOF';
    ⎛  1      ⎞
3 * ⎜ ‒‒‒ + y ⎟
    ⎝  2      ⎠
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "powers can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
          ^
         / \
        3   2
EOF

  my $expected = <<'EOF';
 2
3
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "powers with braces can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
          ^
         / \
        /   2
       / \
      1   x
EOF

  my $expected = <<'EOF';
       2
⎛  1  ⎞
⎜ ‒‒‒ ⎟
⎝  x  ⎠
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "powers with braces can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
          ^
         / \
        x   /
        ^  / \
          1   2
EOF

  my $expected = <<'EOF';
  1
 ‒‒‒
  2
x
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "negation can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
         neg
          |
          /
         / \
        1   2
EOF

  my $expected = <<'EOF';
  1
-‒‒‒
  2
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "negation in addition can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
        +
       / \
      1  neg
      ^   |
          2
EOF

  my $expected = <<'EOF';
1 + (-2)
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "negation in addition can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
              *
             / \
            ^   5
          /   \
        +       /
       / \     / \
      1   /   1   2
      ^  / \
        1   n
EOF

  my $expected = <<'EOF';
            1
           ‒‒‒
            2
⎛      1  ⎞
⎜ 1 + ‒‒‒ ⎟    * 5
⎝      n  ⎠
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "function call can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = <<'EOF';
             f
            / \
           /  sqrt
          / \   |
         1   n  2
EOF

  my $expected = <<'EOF';
  ⎛  1     ┌─── ⎞
f ⎜ ‒‒‒ , ╲│ 2  ⎟
  ⎝  n          ⎠
EOF

  my $result = $printer->to_string(tree($tree));

  is($result."\n", $expected);
};

subtest "number in scientific notation can be printed" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $tree = "0.1e-15";

  my $expected = "0.1e-15";

  my $result = $printer->to_string(tree($tree));

  is($result, $expected);
};

subtest "'pi' is replaced by greek letter" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $expression = $parser->parse("pi");

  my $expected = "π";

  my $result = $printer->to_string($expression);

  is($result, $expected);
};

subtest "sum function is printed pretty" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $expression = $parser->parse("sum(1/n,n,1,100)");

  my $expected = <<'EOF';
 100   1
  ∑   ‒‒‒
n = 1  n
EOF

  my $result = $printer->to_string($expression);

  is($result."\n", $expected);
};

subtest "double subtraction uses braces" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $parser = MCalc::Parser->new();
  my $expression = $parser->parse("5-(3-2)");

  my $result = $printer->to_string($expression);

  my $expected = "5 - ( 3 - 2 )";

  is($result, $expected);
};

subtest "double subtraction uses braces" => sub {
  my $printer = MCalc::PrettyPrinter->new();
  my $parser = MCalc::Parser->new();
  my $expression = $parser->parse("5-(3-2)");

  my $result = $printer->to_string($expression);

  my $expected = "5 - ( 3 - 2 )";

  is($result, $expected);
};

done_testing();
