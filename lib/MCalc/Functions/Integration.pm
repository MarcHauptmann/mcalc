package MCalc::Functions::Integration;

use Moose;
use MCalc::Evaluator;
use MCalc::CompoundContext;
use Math::Complex qw(sqrt);
use POSIX;
use Tree;

with "MCalc::Evaluateable";

has "samplingPoints" => (isa => "ArrayRef",
                         is => "rw",
                         default => sub {
                           return [ -1/3*sqrt(5+2*sqrt(10/7)),
                                    -1/3*sqrt(5-2*sqrt(10/7)),
                                    0,
                                    1/3*sqrt(5-2*sqrt(10/7)),
                                    1/3*sqrt(5+2*sqrt(10/7)) ];
                         });

has "weights" => (isa => "ArrayRef",
                  is => "rw",
                  default => sub {
                    return [ (322-13*sqrt(70))/900,
                             (322+13*sqrt(70))/900,
                             128/225,
                             (322+13*sqrt(70))/900,
                             (322-13*sqrt(70))/900 ];
                  });

sub integrate {
  my ($this, $context, $function, $var, $a, $b) = @_;

  my $int = 0;

  for (my $i=0; $i < scalar(@{$this->weights}); $i++) {
    my $x = ($b + $a)/2 + ${$this->samplingPoints}[$i] * ($b - $a)/2;
    my $alpha = ${$this->weights}[$i];

    $context->setVariable($var->value, $x);

    $int += $alpha * evaluateTree($context, $function)->value();
  }

  return ($b-$a) * $int / 2;
}

sub evaluate {
  my ($this, $context, $expression, $var, $from, $to) = @_;

  my $a = evaluateTree($context, $from)->value();
  my $b = evaluateTree($context, $to)->value();

  my $integrationContext = MCalc::CompoundContext->new();
  $integrationContext->addContext($context);

  my $num = POSIX::ceil($b - $a);
  my $delta = ($b - $a) / $num;
  my $int = 0;

  for (my $i = 0; $i<$num; $i++) {
    my $from = $a + $i * $delta;
    my $to = $a + ($i + 1) * $delta;

    $int += $this->integrate($integrationContext, $expression, $var, $from, $to);
  }

  return Tree->new($int);
}

1;
