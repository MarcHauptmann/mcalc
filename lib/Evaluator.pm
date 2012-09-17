package Evaluator;

use Moose;
use Tree;
use Math::Trig;
use Math::Complex;

has "variables" => (is => "rw",
		    isa => "HashRef",
		    default => sub {
		      { "pi" => 3.1415 };
		    });

has "functions" => (is => "rw",
		    isa => "HashRef",
		    default => sub {
		      {
		       "+" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);
			 my $v2 = $$evaluatorRef->evaluate($args[1]);

			 return $v1 + $v2;
		       },
		       "-" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);
			 my $v2 = $$evaluatorRef->evaluate($args[1]);

			 return $v1 - $v2;
		       },
		       "/" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);
			 my $v2 = $$evaluatorRef->evaluate($args[1]);

			 return $v1 / $v2;
		       },
		       "*" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);
			 my $v2 = $$evaluatorRef->evaluate($args[1]);

			 return $v1 * $v2;
		       },
		       "^" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);
			 my $v2 = $$evaluatorRef->evaluate($args[1]);

			 return $v1 ** $v2;
		       },
		       "cot" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);

			 return cot($v1);
		       },
		       "cos" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);

			 return cos($v1);
		       },
		       "sin" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);

			 return sin($v1);
		       },
		       "tan" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);

			 return tan($v1);
		       },
		       "sqrt" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);

			 return sqrt($v1);
		       },
		       "ln" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);

			 return log($v1);
		       },
		       "logn" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);
			 my $v2 = $$evaluatorRef->evaluate($args[1]);

			 return logn($v1, $v2);
		       },
		       "neg" => sub {
			 my ($evaluatorRef, @args) = @_;

			 my $v1 = $$evaluatorRef->evaluate($args[0]);

			 return -$v1;
		       },
		       "=" => sub {
			 my ($evaluator, @args) = @_;

			 my $var = ${$args[0]}->value();
			 my $value = $$evaluator->evaluate($args[1]);

			 $$evaluator->setVariable($var, $value);

			 return "$var = $value";
		       },
		       "sum" => sub {
			 my ($evaluator, $exRef, $varRef, $fromRef, $toRef) = @_;

			 my $var = $$varRef->value();
			 my $from = $$evaluator->evaluate($fromRef);
			 my $to = $$evaluator->evaluate($toRef);

			 my $result = 0;

			 my $oldVar = $$evaluator->getVariable($var);

			 for(my $i=$from; $i<=$to; $i++) {
			   $$evaluator->setVariable($var, $i);
			   $result += $$evaluator->evaluate($exRef);
			 }

			 $$evaluator->setVariable($var, $oldVar);

			 return $result;
		       }
		     }
		    });

sub getCompletions {
  my $this = shift;
  my @values = ();

  foreach my $val (keys %{$this->variables}) {
    if($val =~ /^$_[0]/) {
      push @values, $val;
    }
  }

  foreach my $val (keys %{$this->functions}) {
    if($val =~ /^$_[0]/) {
      push @values, $val;
    }
  }

  return @values;
}

sub getVariable {
  my ($this, $key) = @_;

  return ${$this->variables}{$key};
}

sub setVariable {
  my ($this, $key, $value) = @_;

  ${$this->variables}{$key} = $value;
}

sub evaluate {
  my ($this, $treeRef) = @_;
  my $tree = $$treeRef;
  my $val = $tree->value();

  if($tree->size() == 1) {
    if($val =~ /[a-zA-Z]+/) {
      return $this->getVariable($val);
    } else {
      return $val;
    }
  } else {
    my $func = ${$this->functions}{$tree->value()};

    my @args = map { \$_ } $tree->children();

    return &{$func}(\$this, @args);
  }
}

1;
