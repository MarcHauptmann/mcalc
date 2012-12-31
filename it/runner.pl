#!/usr/bin/perl

use IPC::Open2;
use Time::HiRes qw(usleep);

my ($out, $in);
my $pid = open2($out, $in, "perl -I lib bin/mcalc");
my $output;

open(INPUT, "it/input");

while (<INPUT>) {
  $output = "";
  my $read;
  sysread($out, $read, 2048);

  $output .= $read;

  if ($output =~ /> $/) {
    print $output;
  }

  usleep(100000);

  my $command = $_;

  print $in $command;
}

usleep(100000);

sysread($out, $output, 1024);
print $output;

close $in;
close $out;
close INPUT;

waitpid($pid, 0);

# exit;
