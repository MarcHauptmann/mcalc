use Module::Build;

my $class = Module::Build->subclass(clazz => "Module::Build::Custom",
                                    code => <<'SUBCLASS');

sub ACTION_deb {
  my ($self) = @_;

  my @libs = ("libterm-readline-gnu-perl",
              "perl-base", "libtree-perl",
              "perl-modules");

  my $deps = join(",", @libs);

  $self->depends_on("distdir");
  $self->do_system("dh-make-perl --build -p mcalc --depends $deps -e marc.hauptmann\@stud.uni-hannover.de ".$self->dist_dir);
}
SUBCLASS

my $builder = $class->new
  (
   module_name => "MCalc",
   dist_version_from => "bin/mcalc",
   dist_author => "Marc Hauptmann <marc.hauptmann@stud.uni-hannover.de>",
   dist_abstract => "calculator",
   license => "apache",
   requires => {
                "Term::ReadLine::Gnu" => 0,
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
                     },
   configure_requires => {
                          "Module::Build" => 0.38
                         },
   recursive_test_files => 1
  );


$builder->create_build_script();
