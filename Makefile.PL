use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Set::Range',
    'VERSION_FROM'	=> 'Range.pm', # finds $VERSION
    'PREREQ_PM'		=> { Date::Calc => 4.0 }, # e.g., Module::Name => 1.1
);
