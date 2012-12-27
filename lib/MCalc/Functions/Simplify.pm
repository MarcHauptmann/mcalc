package MCalc::Functions::Simplify;

use Moose;
use Tree;
use POSIX;
use MCalc::SimplePrinter;
use MCalc::Printer;
use MCalc::Language;
use MCalc::Evaluator;
use MCalc::Util::Rule;
use MCalc::Util::Simplification;

with "MCalc::Evaluateable";

has "rules" => (isa => "ArrayRef",
                is => "rw",
                default => sub { return [] });

sub BUILD {
  my ($this) = @_;

  $this->addRule("varA*(varB*varC)=(varA*varB)*varC", "multiplication is associative");

  $this->addRule("varA*varB=varB*varA", "multiplication is commutative");
  $this->addRule("varA+varB=varB+varA", "addition is commutative");

  $this->addRule("var*1=var", "multiplication by 1");
  $this->addRule("0*var=0", "multiplication by 0");
  $this->addRule("var+0=var", "addition of 0");

  $this->addRule("var-var=0", "substraction is 0");
  $this->addRule("var/var=1", "division results in one");
}

sub addRule {
  my ($this, $expression, $desc) = @_;

  push $this->rules, MCalc::Util::Rule->new($expression, $desc);
}

sub evaluate {
  my ($this, $context, $tree) = @_;

  my @trees = $this->simplify($context, $tree);

  my $min = LONG_MAX;
  my $finalResult = undef;

  my $printer = MCalc::SimplePrinter->new();

  foreach my $result (@trees) {
    # printf "got %s\n", $printer->to_string($result);

    if (complexity($result) < $min) {
      $finalResult = $result;
      $min = complexity($finalResult);
    }
  }

  return $finalResult;
}

sub simplify {
  my ($this, $context, $tree) = @_;

  my @simplifidTrees = ($tree->clone);

  my $printer = MCalc::SimplePrinter->new();
  # printf "simplifying %s\n", $printer->to_string($tree);

  # simplify children
  for (my $i = 0; $i < scalar($tree->children()); $i++) {
    foreach my $newChild ($this->simplify($context, $tree->children($i))) {
      my $newTree = $tree->clone();
      $newTree->remove_child($i);
      $newTree->add_child({ at => $i }, evaluateTree($context, $newChild));

      $this->appendTree(\@simplifidTrees, $newTree);
    }
  }

  @simplifidTrees = $this->getCombinations(@simplifidTrees);

  # applying rules to all new trees
  my @resultTrees = ();

  foreach my $treeToSimplify (@simplifidTrees) {
    my @newRules = $this->applyRules($context, $treeToSimplify, 2);

    $this->appendTree(\@resultTrees, @newRules);
  }

  return @resultTrees;
}

sub getCombinations {
  my ($this, @trees) = @_;

  my @newTrees = ();

  foreach my $tree (@trees) {
    $this->appendTree(\@newTrees, $tree->clone);

    for (my $i=0; $i<scalar($tree->children); $i++) {
      foreach my $otherTree (@trees) {
        my $newTree = $tree->clone();

        $newTree->remove_child($i);
        $newTree->add_child({at => $i}, $otherTree->children($i)->clone);

        $this->appendTree(\@newTrees, $newTree);
      }
    }
  }

  return @newTrees;
}

sub appendTree {
  my ($this, $listRef, @trees) = @_;

  foreach my $tree (@trees) {
    my $contains = 0;

    # check whether tree already in list
    foreach my $elem (@{$listRef}) {
      $contains = $contains || trees_equal($elem, $tree);
    }

    # append if not in list
    if (not($contains)) {
      push @{$listRef}, $tree;
    }
  }
}

sub applyRules {
  my ($this, $context, $tree, $num) = @_;

  my $printer = MCalc::SimplePrinter->new();

  # printf "applyRules for %s (%d)\n", $printer->to_string($tree), $num;

  if ($num == 0) {
    return ($tree->clone);
  } else {
    my @results = ($tree->clone);
    my @rules = $this->findMatchingRules($tree);

    foreach my $rule (@rules) {
      my $result = evaluateTree($context, $rule->apply($tree));

      # printf "-> %s\n", $printer->to_string($result);

      $this->appendTree(\@results, $result);
      $this->appendTree(\@results, $this->applyRules($context, $result, $num-1));
    }

    return @results;
  }
}

sub findMatchingRules {
  my ($this, $tree) = @_;

  my @rules = ();

  foreach my $rule (@{$this->rules}) {
    if ($rule->matches($tree)) {
      push @rules, $rule;
    }
  }

  return @rules;
}

1;
