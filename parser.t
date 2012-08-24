#!/usr/bin/perl

use parser;
use Test::More;

# einfache Operationen
ok(parse("1+1"), "'1+1' wird akzeptiert");
ok(!parse("a+a"), "'a+a' wird nicht akzeptiert");

ok(parse("1.1+3.2"), "Floats werden akzeptiert");

# mehrere Operationen
ok(parse("1"), "eine Zahl wird akzeptiert");
ok(parse("1+1+1"), "zwei Additionen werden akzeptiert");

done_testing();
