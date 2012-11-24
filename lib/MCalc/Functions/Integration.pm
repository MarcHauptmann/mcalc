package MCalc::Functions::Integration;

use Moose;
use MCalc::Evaluator;
use MCalc::CompoundContext;
use Math::Complex;

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

sub evaluate {
  my ($this, $context, $expression, $var, $from, $to) = @_;

  my $a = evaluateTree($context, $from);
  my $b = evaluateTree($context, $to);

  my $integrationContext = MCalc::CompoundContext->new();
  $integrationContext->addContext($context);

  my $int = 0;

  for (my $i=0; $i < scalar(@{$this->weights}); $i++) {
    my $x = ($b + $a)/2 + ${$this->samplingPoints}[$i] * ($b - $a)/2;
    my $alpha = ${$this->weights}[$i];

    $integrationContext->setVariable($var->value, $x);

    $int += $alpha * evaluateTree($integrationContext, $expression);
  }

  return ($b-$a) * $int / 2;
}

1;
