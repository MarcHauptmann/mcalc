package parser;

use Exporter;

our @ISA=qw(Exporter);
our @EXPORT_OK=qw(parse);
our @EXPORT = qw(parse);

sub parse {
    my $input = @_[0];

    return $input =~ /^\d+\.?\d*([\+\-\*\/]\d+\.?\d*)*$/;
}

