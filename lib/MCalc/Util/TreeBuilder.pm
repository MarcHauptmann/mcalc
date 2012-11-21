package MCalc::Util::TreeBuilder;

use Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(tree);

sub tree {
  my ($str) = @_;

  $str =~ s/( *\/.*\\ *\n)*( *\/.*\\ *\n)/\2/;

  print "$str\n";

  my @lines = split(/\n/, $str);

  my $root = Tree->new();

  my @parents = ();
  my @children = ($root);

  foreach my $line (@lines) {
    # Linien
    if ($line =~ /\/.*\\|\|/) {
      my $parentIndex = 0;

      foreach my $elem (split(/ */, $line)) {
        if ($elem eq "") {
          next;
        }

        my $child = Tree->new();
        $parents[$parentIndex]->add_child($child);

        push @children, $child;

        if ($elem eq "\\") {
          $parentIndex++;
        }
      }
    } else {
      # print "$line\n";

      my $childIndex = 0;

      foreach $elem (split(/[ \n]*/, $line)) {
        if ($elem != "") {
          my $child = $children[$childIndex++];
          $child->set_value($elem)
        }
      }

      @parents = @children;
      @children = ();
    }
  }

  return $root;
}

1;
