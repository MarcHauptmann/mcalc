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

  # $this->addRule("varA*varB=varB*varA", "multiplication is commutative");
  # $this->addRule("varA+varB=varB+varA", "addition is commutative");

  $this->addRule("var*1=var", "multiplication by 1");
  $this->addRule("1*var=var", "multiplication by 1");
  $this->addRule("var*0=0", "multiplication by 0");
  $this->addRule("0*var=0", "multiplication by 0");
  $this->addRule("var+0=var", "addition of 0");
  $this->addRule("0+var=var", "addition of 0");

  $this->addRule("var-var=0", "substraction is 0");
  $this->addRule("var/var=1", "division results in one");
}

sub addRule {
  my ($this, $expression, $desc) = @_;

  push $this->rules, MCalc::Util::Rule->new($expression, $desc);
}

sub evaluate {
  my ($this, $context, $tree) = @_;

  # my $newTree = $this->simplify($context, $tree);

  # return $newTree;

  my @trees = $this->simplify($context, $tree);


  my $min = LONG_MAX;
  my $finalResult = undef;

  foreach my $result (@trees) {
    printf "checking %s: ", $printer->to_string($result);

    if (complexity($result) < $min) {
      print "ok\n";
      $finalResult = $result;
    } else {
      print "not ok\n";
    }
  }

  return $finalResult;
}

sub simplify {
  my ($this, $context, $tree) = @_;

  my $printer = MCalc::SimplePrinter->new();
  # printf "simplifying %s\n", $printer->to_string($tree);

  # for (my $i = 0; $i < scalar($tree->children()); $i++) {
  # my $newChild = $this->simplify($context, $tree->children($i));

  # $tree->remove_child($i);
  # $tree->add_child({ at => $i }, evaluateTree($context, $newChild));
  # }

  return $this->getResults($context, $tree, 1);
}

sub getResults {
  my ($this, $context, $tree, $num) = @_;

  # printf "level %d\n", $num;

  if ($num == 0) {
    return ($tree);
  } else {
    my @results = ($tree);
    my @rules = $this->findMatchingRules($tree);

    # printf "%d matching rules\n", scalar(@rules);

    foreach my $rule (@rules) {
      printf "applied '%s'\n", $rule->getDescription;

      push @results, evaluateTree($context, $rule->apply($tree->clone));
    }

    # @results = map { $this->getResults($context, $_, $num-1) } @results;

    # printf "%d results\n", scalar(@results);

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
