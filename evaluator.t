#!/usr/bin/perl

use Test::More;
use evaluator;

# einfache Operationen
is(evaluate("1+1"), 2, "1+1=2");
is(evaluate("1-1"), 0, "1-1=0");
is(evaluate("3*5"), 15, "3*5=15");
is(evaluate("8/4"), 2, "8/4=2");

# simple Zahlen
is(evaluate("1"), 1, "Zahlen werden erkannt");

# mehrfache Operationen
is(evaluate("1+1+1"), 3, "1+1+1=3");
is(evaluate("5+2-3"), 4, "5+2-3=4");
is(evaluate("5+2*3"), 11, "5+2*3=11");
is(evaluate("5+2*3+3*3"), 20, "5+2*3+3*3=20");
is(evaluate("7-10/2+2"), 4, "7-10/2+2=4");


done_testing();
