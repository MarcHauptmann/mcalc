package MCalc::Util::TreeBuilder;

use Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(tree);

sub tree {
  my @args = @_;

  my $root = Tree->new(shift @args);
  my $parent = $root;

  while (scalar(@args) > 0) {
    my $value = shift(@args);

    if (defined($value)) {
      my $child = Tree->new($value);
      $parent->add_child($child);
      $parent = $child;
    } else {
      $parent = $parent->parent();
    }
  }

  return $root;
}

1;
