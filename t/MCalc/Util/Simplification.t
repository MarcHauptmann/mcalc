#!/usr/bin/perl

use Test::More;
use Test::Exception;
use MCalc::Util::TreeBuilder;

BEGIN {
  use_ok("MCalc::Util::Simplification", qw(rule_matches extract_values trees_equal substitute));
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

done_testing();
