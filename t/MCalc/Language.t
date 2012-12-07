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

subtest "an number can be checked" => sub {
  is(is_number("123.1"), 1, "123.1 is number");
  is(is_number("test"), 0, "'test' is no number");
};

subtest "operator weights can be checked" => sub {
  cmp_ok(operator_weight("+"), "<", operator_weight("*"));
  cmp_ok(operator_weight("*"), "<", operator_weight("^"));
};

subtest "keywords can be checked" => sub {
  ok(is_keyword("bye"), "'bye' is keyword");
  ok(is_keyword("quit"), "'quit' is keyword");
  ok(is_keyword("exit"), "'exit' is keyword");
};

done_testing();
