use Module::Build;

my $builder = Module::Build->new(
				 module_name => "MCalc",
				 dist_version => "0.0.1",
				 dist_author => "Marc Hauptmann",
				 dist_abstract => "caclculator"
);

$builder->create_build_script();
