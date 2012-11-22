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

done_testing();
