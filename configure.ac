AC_INIT([mcalc], [0.0.1], [marc.hautpmann@stud.uni-hannover.de])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AC_PATH_PROG(PERL, perl, no)
AC_PATH_PROG(PP, pp, no)
AC_PATH_PROG(PODSELECT, podselect, no)
AC_PATH_PROG(PODTOMAN, pod2man, no)
AC_PATH_PROG(PODTOTEXT, pod2text, no)
AC_PATH_PROG(PROVE, prove, no)
AC_CONFIG_FILES([Makefile])	

# Perl-Module checken
AX_PROG_PERL_MODULES(Term::ReadLine Getopt::Long PAR Tree Math::Complex Math::Trig Test::Exception Moose)

AC_OUTPUT

