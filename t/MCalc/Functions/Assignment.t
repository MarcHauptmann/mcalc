#!/usr/bin/perl

use Test::More;
use Test::Exception;
use MCalc::SimpleContext;
use MCalc::Functions::UserFunction;
use MCalc::Util::TreeBuilder;

BEGIN {
  use_ok("MCalc::Functions::Assignment");
}

subtest "variable can be assigned" => sub {
  my $context = MCalc::SimpleContext->new();
  my$assignment = MCalc::Functions::Assignment->new();

  my $stmt = Tree->new("=");
  $stmt->add_child(Tree->new("var"));
  $stmt->add_child(Tree->new("1"));

  $assignment->evaluate(\$context, \tree("var"), \tree("1"));

  isnt($context->getVariable("var"), undef, "var ist definiert");
  is($context->getVariable("var"), 1, "var ist 1");
};

subtest "variable name must be string" => sub {
  my $context = MCalc::SimpleContext->new();
  my $assignment = MCalc::Functions::Assignment->new();

  throws_ok { $assignment->evaluate(\$context, \tree("3"), \tree("5")) }
    "Error::Simple";
};

subtest "function can be assigned" => sub {
  my $context = MCalc::SimpleContext->new();
  my $assignment = MCalc::Functions::Assignment->new();

  my $lhs = <<EOF;
        f
       / \\
      x   y
EOF

  my $rhs = <<EOF;
      +
     / \\
    x   y
EOF

  my $lhsTree = tree($lhs);
  my $rhsTree = tree($rhs);

  $assignment->evaluate(\$context, \$lhsTree, \$rhsTree);

  my $expected = MCalc::Functions::UserFunction->new(arguments => ["x", "y"],
                                                     body => $rhsTree,
                                                     name => "f");

  ok($context->functionIsDefined("f"));
  is_deeply($context->getFunction("f"), $expected, "function matches");
};

subtest "function argument must be tree with size 1" => sub {
  my $context = MCalc::SimpleContext->new();
  my $assignment = MCalc::Functions::Assignment->new();

  my $lhs = <<EOF;
        f
        |
        +
       / \\
      x   3
EOF

  my $lhsTree = tree($lhs);

  throws_ok { $assignment->evaluate(\$context, \$lhsTree, \tree("x")) }
    "Error::Simple";
};

subtest "a operator may not be redefined" => sub {
  my $context = MCalc::SimpleContext->new();
  my $assignment = MCalc::Functions::Assignment->new();

  my $lhs = <<EOF;
        +
       / \\
      x   3
EOF

  my $lhsTree = tree($lhs);

  throws_ok { $assignment->evaluate(\$context, \$lhsTree, \tree("x")) }
    "Error::Simple";
};

done_testing();
