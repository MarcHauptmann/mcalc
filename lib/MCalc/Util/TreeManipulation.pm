package MCalc::Util::TreeManipulation;

use strict;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(get_equal_trees);

sub get_equal_trees {
  my ($tree) = @_;

  my @trees = ($tree->clone());

  push @trees, map { flip_children($_->clone) } @trees;

  return @trees;
}

sub flip_children {
  my ($tree) = @_;

  my @children = $tree->children();

  foreach my $child (@children) {
    $tree->remove_child($child);
  }

  @children = reverse @children;

  foreach my $child (@children) {
    $tree->add_child($child);
  }

  return $tree;
}

1;
