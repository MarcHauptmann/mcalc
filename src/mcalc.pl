use parser;
use evaluator;
use Term::ReadLine;
use Getopt::Long;
use Pod::Usage;
use PAR;

our $VERSION = "0.0.1";

our $help = 0;
our $prompt = "mcalc>";
our $silent=0;
our $verbose = 0;
our $version = 0;

# Hier geht es los!

sub printWelcome {
  print "Welcome to mcalc v$VERSION\n"
}

sub printVersion {
  print "mcalc v$VERSION by Marc Hauptmann\n"
}

sub batch {
  calculate($_[0]);

  exit;
}

sub calculate {
  my $input = $_[0];

  eval {
    # parsen
    my $tree = parse($input);

    # auswerten
    my $result = evaluate(\$tree);

    printf "$result\n";
  };
  if (my $error = $@) {
    print $error;
  }
}

GetOptions(
	   "help" => \$help,
	   "prompt|p=s" => \$prompt,
	   "silent|s" => \$silent,
	   "version" => \$version,
	   "<>" => \&batch
);

if($help) {
  $help = PAR::read_file("help.txt");

  print $help;
}
elsif($version) {
  printVersion();
}
else {
  if (!$silent) {
    printWelcome();
  }

  my $term = Term::ReadLine->new("mcalc");

  while (1) {
    my $input = $term->readline("$prompt ");

    # Leerzeichen entfernen
    $input =~ s/\s//g;

    # Sonderbehandlung für 'quit'
    if ($input =~ /^(quit|bye|exit)$/) {
      if(!$silent) {
	print "bye :)\n";
      }

      exit;
    }

    calculate($input);
  }
}

__END__

