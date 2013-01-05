#!/usr/bin/perl

use Test::More;
use Test::Exception;
use MCalc::Util::TreeBuilder;

BEGIN {
  use_ok("MCalc::Parser");
}

subtest "eine Zahl" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("1");

  is_deeply($tree, tree("1"), "result matches");
};

subtest "Addition" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("1+2");

  my $expectedTree = <<'EOF';
          +
         / \
        1   2
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Bruch mal Kehrwert" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("1/2*2");

  my $expectedTree = <<'EOF';
             *
            / \
           /   2
          / \
         1   2
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "addition of three numbers" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("1+2+3");

  my $expectedTree = <<'EOF';
        +
       / \
      1   +
      ^  / \
        2   3
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "subtraction of three numbers" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("3-2-1");

  my $expectedTree = <<'EOF';
       -
      / \
     -   1
    / \
   3   2
EOF

  is_deeply($tree, tree($expectedTree));
};

subtest "subtraction of three numbers" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("3-2+2-1");

  my $expectedTree = <<'EOF';
        +
      /   \
     -     -
    / \   / \
   3   2 2   1
EOF

  is_deeply($tree, tree($expectedTree));
};

subtest "Operatorrangfolge" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("2*3+4");

  my $expectedTree = <<'EOF';
          +
         / \
        *   4
       / \
      2   3
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Operatorrangfolge" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("2+3*4");

  my $expectedTree = <<'EOF';
          +
         / \
        2   *
        ^  / \
          3   4
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Operatorrangfolge" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("2^3*4");

  my $expectedTree = <<'EOF';
          *
         / \
        ^   4
       / \
      2   3
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Addition zweier Multiplikationen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("2*3+4*5");

  my $expectedTree = <<'EOF';
           +
          / \
         /   \
        *     *
       / \   / \
      2   3 4   5
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "großer Ausdruck" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("2*3+4*5+6");

  my $expectedTree = <<'EOF';
               +
             /   \
            /     \
           *       +
          / \     / \
         2   3   *   6
         ^   ^  / \  ^
               4   5
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Operatorrangfolge" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("2*(3+4)");

  my $expectedTree = <<'EOF';
          *
         / \
        2   +
        ^  / \
          3   4
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Operatorrangfolge" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("(3+4)*2");

  my $expectedTree = <<'EOF';
          *
         / \
        +   2
       / \
      3   4
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Funktionen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("cos(1-1)");

  my $expectedTree = <<'EOF';
            cos
             |
             -
            / \
           1   1
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Funktionen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("cos(1,2,3)");

  my $expectedTree = <<'EOF';
             cos
            / | \
           1  2  3
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Funktionen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("sum(2,5,7)+cos(1,2)");

  my $expectedTree = <<'EOF';
              +
            /   \
           /     \
         sum     cos
        / | \    / \
       2  5  7  1   2
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Variablen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("var");

  is_deeply($tree, tree("var"), "result matches");
};

subtest "Variablen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("1+var");

  my $expectedTree = <<'EOF';
             +
            / \
           1  var
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Variablen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("var=1");

  my $expectedTree = <<'EOF';
             =
            / \
          var  1
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Negierung von Zahlen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("-1");

  my $expectedTree = <<'EOF';
          neg
           |
           1
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Negierung von Zahlen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("-2+2");

  my $expectedTree = <<'EOF';
             +
            / \
          neg  2
           |
           2
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "Negierung von Zahlen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("-2^2");

  my $expectedTree = <<'EOF';
            neg
             |
             ^
            / \
           2   2
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "function assignment" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("f(x)=x^2");

  my $expectedTree = <<'EOF';
             =
            / \
           f   ^
           |  / \
           x x   2
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "function assignment" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("f(x,y)=x+y");

  my $expectedTree = <<'EOF';
             =
            / \
           /   \
          f     +
         / \   / \
        x   y x   y
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "function definition with negation" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("f(x)=-x");

  my $expectedTree = <<'EOF';
             =
            / \
           /   \
          f    neg
          |     |
          x     x
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "simple function call works" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("f(x)");

  my $expectedTree = <<'EOF';
          f
          |
          x
EOF

  is_deeply($tree, tree($expectedTree), "result matches");
};

subtest "dies on invalid function definition" => sub {
  my $parser = MCalc::Parser->new();

  throws_ok { $parser->parse("f(x,)=x") } "Error::Simple";
};

subtest "dies on invalid term" => sub {
  my $parser = MCalc::Parser->new();

  throws_ok { $parser->parse("(a+b") } "Error::Simple";
};

subtest "int(x,x,-1,1) can be parsed" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("int(x,x,-1,1)");

  my $expectedTree = <<'EOF';
          int
         /|  |\
       /  |  |  \
      x   x neg  1
      ^   ^  |   ^
             1
EOF

  is_deeply($tree, tree($expectedTree), "tree matches");
};

subtest "parser can be used two times" => sub {
  my $parser = MCalc::Parser->new();


  lives_ok( sub {
              $parser->parse("int(x,x,-1,1)");
              $parser->parse("int(x,x,-1,1)");
            });

};


done_testing();
