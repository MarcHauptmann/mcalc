#!/usr/bin/perl

use Test::More;
use MCalc::Util::TreeBuilder;

BEGIN {
  use_ok("MCalc::Printer");
}

subtest "an addition can be printed" => sub {
  my $printer = MCalc::Printer->new();

  my $tree = <<EOF;
     +
    / \\
   2   3
EOF

  my $result = $printer->to_string(tree($tree));

  is($result, "2 + 3");
};

subtest "a function call can be printed" => sub {
  my $printer = MCalc::Printer->new();

  my $tree = <<EOF;
     f
   / | \\
  x  y  z
EOF

  my $result = $printer->to_string(tree($tree));

  is($result, "f(x, y, z)");
};

subtest "a complex expression can be printed" => sub {
  my $printer = MCalc::Printer->new();

  my $tree = <<EOF;
     +
    / \\
   x   -
   ^  / \\
     3   4
EOF

  my $result = $printer->to_string(tree($tree));

  is($result, "x + 3 - 4");
};

subtest "braces are printed correctly" => sub {
  my $printer = MCalc::Printer->new();

  my $tree = <<EOF;
        *
       / \\
      +   x
     / \\
    3   4
EOF

  my $result = $printer->to_string(tree($tree));

  is($result, "(3 + 4) * x");
};

subtest "'neg' prints minus sign" => sub {
  my $printer = MCalc::Printer->new();

  my $tree = <<EOF;
        neg
         |
         1
EOF

  my $result = $printer->to_string(tree($tree));

  is($result, "-1");
};

subtest "negation of complex expression" => sub {
  my $printer = MCalc::Printer->new();

  my $tree = <<'EOF';
         +
        / \
       3  neg
       ^   |
           4
EOF

  my $result = $printer->to_string(tree($tree));

  is($result, "3 + (-4)");
};

subtest "negation of first operand has no braces" => sub {
  my $printer = MCalc::Printer->new();

  my $tree = <<'EOF';
         +
        / \
      neg  3
       |
       4
EOF

  my $result = $printer->to_string(tree($tree));

  is($result, "-4 + 3");
};

subtest "negation in functions calls does not create braces" => sub {
  my $printer = MCalc::Printer->new();

  my $tree = <<'EOF';
        func
        / \
       1  neg
       ^   |
           1
EOF

  my $result = $printer->to_string(tree($tree));

  is($result, "func(1, -1)");
};

done_testing();
