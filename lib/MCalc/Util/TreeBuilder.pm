package MCalc::Util::TreeBuilder;

use Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(tree);

sub tree {
  my @args = @_;

  @values = split(/[ |\/\\]*/, $args[0]);

  # print join(":", @values)."\n";

  shift @values;

  my $root = Tree->new(shift @values);
  my $parent = $root;

  foreach my $elem (@values) {
    if ($elem eq "\n") {
      if ($parent->size() > 1) {
        $parent = $parent->children(0);
      }

      next;
    }

    my $child = Tree->new($elem);
    $parent->add_child($child);
  }

  return $root;
}

1;
