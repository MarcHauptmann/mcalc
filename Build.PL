use Module::Build;

my $builder = Module::Build->new
(
 module_name => "MCalc",
 dist_version_from => "bin/mcalc",
 dist_author => "Marc Hauptmann <marc.hauptmann@stud.uni-hannover.de",
 dist_abstract => "caclculator",
 requires => {
	      "Term::ReadLine" => 0,
	      "Getopt::Long" => 0,
	      "Pod::Usage" => 0,
	      "Moose" => 0,
	      "Tree" => 0,
	      "Math::Trig" => 0,
	      "Math::Complex" => 0
	     },
 build_requires => {
		    "Test::More" => 0,
		    "Test::Exception" => 0
		   }
);

$builder->create_build_script();
