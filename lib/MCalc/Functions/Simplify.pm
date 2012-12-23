package MCalc::Functions::Simplify;

use Moose;
use Tree;
use MCalc::Printer;
use MCalc::Language;
use MCalc::Evaluator;
use MCalc::Util::Rule;

with "MCalc::Evaluateable";

has "rules" => (isa => "ArrayRef",
                is => "rw",
                default => sub { return [] });

sub BUILD {
  my ($this) = @_;

  $this->addRule("var*1=var", "multiplication by 1");
  $this->addRule("1*var=var", "multiplication by 1");
  $this->addRule("var*0=0", "multiplication by 0");
  $this->addRule("0*var=0", "multiplication by 0");
  $this->addRule("var+0=var", "addition of 0");
  $this->addRule("0+var=var", "addition of 0");

  $this->addRule("var-var=0", "substraction is 0");
  $this->addRule("var/var=1", "division is one");
}

sub addRule {
  my ($this, $expression, $desc) = @_;

  push $this->rules, MCalc::Util::Rule->new($expression, $desc);
}

sub evaluate {
  my ($this, $context, $tree) = @_;

  my $newTree = $this->simplify($tree);

  return $newTree;
}

sub simplify {
  my ($this, $tree) = @_;

  # print "simplifying ".join(" ", map {$_->value} $tree->traverse($tree->PRE_ORDER))."\n";

  for (my $i = 0; $i < scalar($tree->children()); $i++) {
    my $newChild = $this->simplify($tree->children($i));

    $tree->remove_child($i);
    $tree->add_child({ at => $i }, $newChild->clone);

    # print $i.": ".join(" ", map {$_->value} $tree->traverse($tree->PRE_ORDER))."\n";
  }

  foreach my $rule (@{$this->rules}) {
    if ($rule->matches($tree)) {
      # printf "applied '%s'\n", $rule->getDescription;

      return $rule->apply($tree);
    }
  }

  # print "result: ".join(" ", map {$_->value} $tree->traverse($tree->PRE_ORDER))."\n";

  return $tree->clone;
}

1;
