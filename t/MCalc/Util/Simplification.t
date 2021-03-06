#!/usr/bin/perl

use Test::More;
use Test::Exception;
use MCalc::Util::TreeBuilder;
use MCalc::Parser;

our $parser = MCalc::Parser->new();

BEGIN {
  use_ok("MCalc::Util::Simplification", qw(rule_matches extract_values trees_equal substitute complexity));
}

use MCalc::Util::Simplification qw(trees_equal);

sub not_ok {
  my ($got, $message) = @_;

  ok(not($got), $message);
}

subtest "a simple rule matches" => sub {
  my $rule = "1";
  my $expression = "1";

  ok(rule_matches(tree($rule), tree($expression)));
};


subtest "a simple rule does not matche" => sub {
  my $rule = "2";
  my $expression = "1";

  not_ok(rule_matches(tree($rule), tree($expression)));
};

subtest "a simple rule with variable matches" => sub {
  my $rule = "a";
  my $expression = "1";

  ok(rule_matches(tree($rule), tree($expression)));
};

subtest "addition rule matches" => sub {
  my $rule = <<'EOF';
    +
   / \
  1   2
EOF
  my $expression = <<'EOF';
    +
   / \
  1   2
EOF

  ok(rule_matches(tree($rule), tree($expression)));
};

subtest "addition rule does not match" => sub {
  my $rule = <<'EOF';
    +
   / \
  1   3
EOF
  my $expression = <<'EOF';
    +
   / \
  1   2
EOF

  not_ok(rule_matches(tree($rule), tree($expression)));
};

subtest "addition rule does not match" => sub {
  my $rule = <<'EOF';
    +
   / \
  1   3
EOF
  my $expression = <<'EOF';
    +
   / \
  1   2
EOF

  not_ok(rule_matches(tree($rule), tree($expression)));
};

subtest "addition rule with variables matches" => sub {
  my $rule = <<'EOF';
    +
   / \
  a   b
EOF
  my $expression = <<'EOF';
    +
   / \
  1   2
EOF

  ok(rule_matches(tree($rule), tree($expression)));
};

subtest "rule only with unique values" => sub {
  my $rule = <<'EOF';
    +
   / \
  a   a
EOF
  my $expression = <<'EOF';
    +
   / \
  1   2
EOF

  not_ok(rule_matches(tree($rule), tree($expression)));
};

subtest "rule for associativity matches" => sub {
  my $rule = <<'EOF';
      *
     / \
    *   c
   / \
  a   b
EOF
  my $expression = <<'EOF';
        *
      /   \
    *      /
   / \    / \
  1   2  3   4
EOF

  ok(rule_matches(tree($rule), tree($expression)));
};

################################################################################

subtest "trees with size 1 can be equal" => sub {
  my $tree1 = tree("1");
  my $tree2 = tree("1");

  ok(trees_equal($tree1, $tree2));
};

subtest "trees with size 1 can be not equal" => sub {
  my $tree1 = tree("1");
  my $tree2 = tree("2");

  not_ok(trees_equal($tree1, $tree2));
};

subtest "trees with size 3 can be equal" => sub {
  my $tree1 = <<'EOF';
     +
    / \
   1   2
EOF
  my $tree2 = <<'EOF';
     +
    / \
   1   2
EOF

  ok(trees_equal(tree($tree1), tree($tree2)));
};


subtest "trees with size 3 can not be equal" => sub {
  my $tree1 = <<'EOF';
     +
    / \
   1   3
EOF
  my $tree2 = <<'EOF';
     +
    / \
   1   2
EOF

  not_ok(trees_equal(tree($tree1), tree($tree2)));
};

subtest "emptry tree on left size is not equal" => sub {
  my $tree1 = <<'EOF';
     +
     |
     2
EOF
  my $tree2 = <<'EOF';
     +
    / \
   1   2
EOF

  not_ok(trees_equal(tree($tree1), tree($tree2)));
};

subtest "emptry tree on right size is not equal" => sub {
  my $tree1 = <<'EOF';
     +
     |
     1
EOF
  my $tree2 = <<'EOF';
     +
    / \
   1   2
EOF

  not_ok(trees_equal(tree($tree1), tree($tree2)), "trees sould not be equal");
};

################################################################################

subtest "value for variable can be extracted" => sub {
  my $rule = "a";
  my $expression = "1";

  my %expected = (a => tree(1));

  my %result = extract_values(tree($rule), tree($expression));

  is_deeply(\%result, \%expected);
};

subtest "variable on right side in addition can be extracted" => sub {
  my $rule = <<'EOF';
      +
     / \
    1   a
EOF
  my $expression = <<'EOF';
      +
     / \
    1   2
EOF
  my %expected = (a => tree(2));

  my %result = extract_values(tree($rule), tree($expression));

  is_deeply(\%result, \%expected);
};

subtest "variable on left side in addition can be extracted" => sub {
  my $rule = <<'EOF';
      +
     / \
    a   2
EOF
  my $expression = <<'EOF';
      +
     / \
    1   2
EOF
  my %expected = (a => tree(1));

  my %result = extract_values(tree($rule), tree($expression));

  is_deeply(\%result, \%expected);
};

subtest "different variable values throw exception" => sub {
  my $rule = <<'EOF';
      +
     / \
    a   a
EOF
  my $expression = <<'EOF';
      +
     / \
    1   2
EOF

  dies_ok( sub { extract_values(tree($rule), tree($expression)) } );
};

subtest "same variable values do not throw exception" => sub {
  my $rule = <<'EOF';
      +
     / \
    a   a
EOF
  my $expression = <<'EOF';
      +
     / \
    1   1
EOF

  lives_ok( sub { extract_values(tree($rule), tree($expression)) } );
};

subtest "..." => sub {
  my $rule = $parser->parse("(a*b)*c");
  my $expression = $parser->parse("((2*x)*3)*4");

  my $expected_a = $parser->parse("2*x");
  my $expected_b = $parser->parse("3");
  my $expected_c = $parser->parse("4");

  my %values = extract_values($rule, $expression);

  is_deeply($values{"a"}, $expected_a, "a is 2*x");
  is_deeply($values{"b"}, $expected_b, "b is 3");
  is_deeply($values{"c"}, $expected_c, "c is 4");
};

################################################################################

subtest "simple value is not substituted" => sub {
  my $expression = "1";
  my %values = (a => tree("1"), b => tree("2"));

  my $result = substitute(tree($expression), %values);

  is_deeply($result, tree($expression));
};

subtest "variable is substituted" => sub {
  my $expression = "a";
  my %values = (a => tree("1"), b => tree("2"));

  my $result = substitute(tree($expression), %values);
  my $expected = tree("1");

  is_deeply($result, $expected);
};

subtest "variable in complex expression can be substituted" => sub {
  my $expression = <<'EOF';
    +
   / \
  1   a
EOF

  my %values = (a => tree("3"), b => tree("2"));

  my $result = substitute(tree($expression), %values);

  my $expected = <<'EOF';
    +
   / \
  1   3
EOF

  is_deeply($result, tree($expected));
};

subtest "variables in associativity rule can be substituted" => sub {
  my $expression = <<'EOF';
    +
   / \
  a   +
  ^  / \
    b   c
EOF

  my %values = (a => tree("3"), b => tree("2"), c => tree(1));

  my $result = substitute(tree($expression), %values);

  my $expected = <<'EOF';
    +
   / \
  3   +
  ^  / \
    2   1
EOF

  is_deeply($result, tree($expected));
};

################################################################################

subtest "a sum is more complex than a number" => sub {
  my $sum = <<'EOF';
   +
  / \
 2   1
EOF

  cmp_ok(complexity(tree($sum)), ">", complexity(tree("3")));
};

done_testing();
