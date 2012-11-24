#!/usr/bin/perl

use Test::More;
use Test::Exception;
use MCalc::Util::TreeBuilder;

BEGIN {
  use_ok("MCalc::Parser");
}

sub getTokens {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse($_[0]);

  my @preorder = map { $_->value() } $tree->traverse($tree->PRE_ORDER);

  print "# Rückgabe: ";
  foreach (@preorder) {
    print $_." ";
  }
  print "\n";

  return @preorder;
}

print <<"EOF";
# ----------------------------------------
# Teste parsen einer Zahl
EOF

subtest "eine Zahl" => sub {
  my @tokens = getTokens("1");

  is_deeply(\@tokens, [1], "Ergebnis stimmt");
};

print <<"EOF";
# ----------------------------------------
# Teste Parsen einer Addition
# erwarteter Baum:
#          +
#         / \\
#        1   2
#
# preorder: + 1 2
EOF

subtest "Addition" => sub {
  my @tokens = getTokens("1+2");

  is_deeply(\@tokens, ["+", 1, 2], "Ergebnis stimmt");
};

print <<"EOF";
# ----------------------------------------
# Teste Bruch mal Kehrwert
# Eingabe: -2^2
# erwarteter Baum:
#             *
#            / \\
#           /   2
#          / \\
#         1   2
EOF

subtest "Bruch mal Kehrwert" => sub {
  my @tokens = getTokens("1/2*2");

  is_deeply(\@tokens, ["*", "/", 1, 2, 2], "Ergebnis passt");
};


print <<"EOF";
# ----------------------------------------
# Teste Parsen einer Addition von drei Zahlen
# Eingabe: 1+2+3
# erwarteter Baum:
#        +
#       / \\
#      1   +
#         / \\
#         2   3
#
# preorder: + 1 + 2 3
EOF

subtest "3-er Addition" => sub {
  my @tokens = getTokens("1+2+3");

  is_deeply(\@tokens, ["+", 1, "+", 2, 3], "Ergebnis stimmt");
};

print <<"EOF";
# ----------------------------------------
# Teste Beachtung der Operatorrangfolge
# Eingabe: 2*3+4
# erwarteter Baum:
#          +
#         / \\
#        *   4
#       / \\
#      2   3
#
# preorder: + * 2 3 4
EOF

subtest "Operatorrangfolge" => sub {
  my @tokens = getTokens("2*3+4");

  is_deeply(\@tokens, ["+", "*", 2, 3, 4], "Ergebnis stimmt");
};

print <<"EOF";
# ----------------------------------------
# Teste Beachtung der Operatorrangfolge
# Eingabe: 2+3*4
# erwarteter Baum:
#          +
#         / \\
#        2   *
#           / \\
#          3   4
#
# preorder: + 2 * 3 4
EOF

subtest "Operatorrangfolge" => sub {
  my @tokens = getTokens("2+3*4");

  is_deeply(\@tokens, ["+", 2, "*", 3, 4]);
};


print <<"EOF";
# ----------------------------------------
# Teste Operatorrangfolge mit Potenzieren
# Eingabe: 2^3*4
# erwarteter Baum:
#          *
#         / \\
#        ^   4
#       / \\
#      2   3
#
# preorder: * ^ 2 3 4
EOF

subtest "Operatorrangfolge" => sub {
  my @tokens = getTokens("2^3*4");

  is_deeply(\@tokens, ["*", "^", 2, 3, 4]);
};

print <<"EOF";
# ----------------------------------------
# Teste Addition von zwei Multiplikationen
# Eingabe: 2*3+4*5
# erwarteter Baum:
#           +
#          / \\
#         /   \\
#        *     *
#       / \\   / \\
#      2   3 4   5
#
# preorder: + * 2 3 * 4 5
EOF

subtest "Addition zweier Multiplikationen" => sub {
  my @tokens = getTokens("2*3+4*5");

  is_deeply(\@tokens, ["+", "*", 2, 3, "*", 4, 5], "Ergebnis stimmt");
};

print<<"EOF";
# ----------------------------------------
# Teste großen Ausdruck
# Eingabe: 2*3+4*5+6
# erwarteter Baum:
#              +
#             / \\
#            /   \\
#           *     +
#          / \\   / \\
#         2   3 *   6
#              / \\
#             4   5
#
# preorder: + * 2 3 + * 4 5 6
EOF

subtest "großer Ausdruck" => sub {
  my @tokens = getTokens("2*3+4*5+6");

  is_deeply(\@tokens, ["+", "*", 2, 3, "+", "*", 4, 5, 6], "Ergebnis stimmt");
};

print <<"EOF";
# ----------------------------------------
# Teste Klammerung
# Eingabe: 2*(3+4)
# erwarteter Baum:
#          *
#         / \\
#        2   +
#           / \\
#          4   3
#
# preorder: * 2 + 3 4
EOF

subtest "Operatorrangfolge" => sub {
  my @tokens = getTokens("2*(3+4)");

  is_deeply(\@tokens, ["*", 2, "+", 3, 4], "Ergebnis stimmt");
};


print <<"EOF";
# ----------------------------------------
# Teste Klammerung anders herum
# Eingabe: (3+4)*2
# erwarteter Baum:
#          *
#         / \\
#        +   2
#       / \\
#      3   4
#
# preorder: * + 3 4 2
EOF

subtest "Operatorrangfolge" => sub {
  my @tokens = getTokens("(3+4)*2");

  is_deeply(\@tokens, ["*", "+", 3, 4, 2], "Ergebnis passt");
};

print <<"EOF";
# ----------------------------------------
# Teste Funktionen
# Eingabe: cos(1-1)
# erwarteter Baum:
#            cos
#             |
#             -
#            / \\
#           1   1
EOF

subtest "Funktionen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("cos(1-1)");

  is($tree->size(), 4, "Größe ist 4");
  is($tree->value(), "cos", "Oberste Funktion ist cos");
  is($tree->children(0)->value(), "-", "Operation ist -");
  is($tree->children(0)->children(0)->value, 1, "Kind 1 ist 1");
  is($tree->children(0)->children(1)->value, 1, "Kind 2 ist 1");
};


print <<"EOF";
# ----------------------------------------
# Teste Funktionen mit mehreren Parametern
# Eingabe: cos(1,2,3)
# erwarteter Baum:
#            cos
#            /|\\
#           1 2 3
EOF

subtest "Funktionen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("cos(1,2,3)");

  is($tree->size(), 4, "Größe ist 3");
  is($tree->value(), "cos", "Oberste Funktion ist cos");
  is($tree->children(0)->value, 1, "Kind 1 ist 1");
  is($tree->children(1)->value, 2, "Kind 2 ist 2");
  is($tree->children(2)->value, 3, "Kind 3 ist 3");
};

print <<"EOF";
# ----------------------------------------
# Teste Funktionen
# Eingabe: sum(2,5,7)+cos(1,2)
# erwarteter Baum:
#             +
#            / \\
#           /   \\
#         sum   cos
#         /|\\   / \\
#        2 5 7 1   2
EOF

subtest "Funktionen" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("sum(2,5,7)+cos(1,2)");

  map {print $_->value()." "} $tree->traverse($tree->PRE_ORDER);
  print "\n";

  is($tree->size(), 8, "Größe ist 8");
  is($tree->value(), "+", "Operation ist +");
  is($tree->children(0)->value(), "sum", "erster Zweig ist sum");
  is($tree->children(0)->size(), 4, "sum-Tree hat Größe 4");

  my @sum_elements = map { $_->value() } $tree->children(0)->children();
  is_deeply(\@sum_elements, [2, 5, 7], "Elemente stimmen");

  is($tree->children(1)->value(), "cos", "zweiter Zweig ist cos");
  is($tree->children(1)->size(), 3, "cos-Tree hat Größe 3");

  my @cos_elements = map { $_->value() } $tree->children(1)->children();
  is_deeply(\@cos_elements, [1, 2], "Elemente stimmen");
};

print <<"EOF";
# ----------------------------------------
# Teste Variablen
# Eingabe: var
# erwarteter Baum:
#             var
EOF

subtest "Variablen" => sub {
  my @tokens = getTokens("var");

  is_deeply(\@tokens, ["var"], "Ergebnis passt");
};


print <<"EOF";
# ----------------------------------------
# Teste Variable in Ausdruck
# Eingabe: var
# erwarteter Baum:
#             1+var
EOF

subtest "Variablen" => sub {
  my @tokens = getTokens("1+var");

  is_deeply(\@tokens, ["+", 1, "var"], "Ergebnis passt");
};

print <<"EOF";
# ----------------------------------------
# Teste Zuweisung
# Eingabe: var=1
# erwarteter Baum:
#             =
#            / \\
#          var  1
EOF

subtest "Variablen" => sub {
  my @tokens = getTokens("var=1");

  is_deeply(\@tokens, ["=", "var", 1], "Ergebnis passt");
};

print <<"EOF";
# ----------------------------------------
# Teste nicht zulässige Zuweisung
# Eingabe: var+1=1
# Exception erwartet
EOF

subtest "Variablen" => sub {
  dies_ok { parse("var+1=1") } "Test";
};

print <<"EOF";
# ----------------------------------------
# Teste Negierung von Zahlen
# Eingabe: -1
# erwarteter Baum:
#          neg
#           |
#           1
EOF

subtest "Negierung von Zahlen" => sub {
  my @tokens = getTokens("-1");

  is_deeply(\@tokens, ["neg", 1], "Ergebnis passt");
};

print <<"EOF";
# ----------------------------------------
# Teste Rechnen mit negativen Zahlen
# Eingabe: -2+2
# erwarteter Baum:
#             +
#            / \\
#          neg  2
#           |
#           2
EOF

subtest "Negierung von Zahlen" => sub {
  my @tokens = getTokens("-2+2");

  is_deeply(\@tokens, ["+", "neg", 2, 2], "Ergebnis passt");
};

print <<"EOF";
# ----------------------------------------
# Teste Potenzieren mit negativem Vorzeichen
# Eingabe: -2^2
# erwarteter Baum:
#            neg
#             |
#             ^
#            / \\
#           2   2
EOF

subtest "Negierung von Zahlen" => sub {
  my @tokens = getTokens("-2^2");

  is_deeply(\@tokens, ["neg", "^", 2, 2], "Ergebnis passt");
};

print <<"EOF";
# ----------------------------------------
# Testing assignment of function
# input: f(x)=x^2
# expected tree:
#             =
#            / \\
#           f   ^
#           |  / \\
#           x x   2
EOF

subtest "function assignment" => sub {
  my @tokens = getTokens("f(x)=x^2");

  is_deeply(\@tokens, ["=", "f", "x", "^", "x", 2], "Ergebnis passt");
};

print <<"EOF";
# ----------------------------------------
# Testing assignment of function with multiple parameters
# input: f(x,y)=x+y
# expected tree:
#             =
#            / \\
#           /   \\
#          f     +
#         / \\   / \\
#        x   y x   y
EOF

subtest "function assignment" => sub {
  my @tokens = getTokens("f(x,y)=x+y");

  is_deeply(\@tokens, ["=", "f", "x", "y", "+", "x", "y"], "Ergebnis passt");
};

subtest "simple function call works" => sub {
  my @tokens = getTokens("f(x)");

  is_deeply(\@tokens, ["f", "x"], "Ergebnis passt");
};

subtest "dies on invalid function definition" => sub {
  throws_ok { getTokens("f(x,)=x") } "Error::Simple";
};

subtest "dies on invalid term" => sub {
  throws_ok { getTokens("(a+b") } "Error::Simple";
};

subtest "int(x,x,-1,1) can be parsed" => sub {
  my $parser = MCalc::Parser->new();
  my $tree = $parser->parse("int(x,x,-1,1)");

  my $expectedTree = <<EOF;
          int
         /|  |\\
       /  |  |  \\
      x   x neg  1
      ^   ^  |   ^
             1
EOF

  is_deeply($tree, tree($expectedTree), "tree matches");
};

done_testing();
