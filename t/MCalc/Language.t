#!/usr/bin/perl

use Test::More;

BEGIN {
  use_ok("MCalc::Language");
}

subtest "a operator can be checked" => sub {
  is(is_operator("+"), 1, "+ is operator");
  is(is_operator("test"), 0, "'test' is no operator");
  is(is_operator("^"), 1, "^ is operator");
};

subtest "an identifiert can be checked" => sub {
  is(is_identifier("test"), 1, "'test' is identifier");
  is(is_identifier("+"), 0, "operator is no identifier");
};

subtest "operator weights can be checked" => sub {
  cmp_ok(operator_weight("+"), "<", operator_weight("*"));
  cmp_ok(operator_weight("*"), "<", operator_weight("^"));
};

done_testing();
