package Set::Range;
use strict;

use vars qw(@ISA @EXPORT);

require Exporter;
require 5.005_03;

use constant DATE_RANGE		=> 1;
use constant NUM_RANGE		=> 2;
use constant TIME_RANGE		=> 3;
use constant EU_DATE_RANGE	=> 4;

@ISA = qw(Exporter);
@EXPORT = qw(DATE_RANGE EU_DATE_RANGE NUM_RANGE TIME_RANGE);
my $VERSION = '1.0';

sub new {
	my $self = shift;
  	my $range = shift;
  	return bless $range, $self;
}


sub getSet {
	my ($self, $var, $type) = @_;
	$type = NUM_RANGE unless $type;

	if (($type == DATE_RANGE) || ($type == EU_DATE_RANGE)) {
		$var = _timify($var, $type);
	}

	my $state = 0;
	foreach $state (keys %$self) {
		my ($u, $l) = ($self->{$state}->{upper}, $self->{$state}->{lower});
		
		if (($type == DATE_RANGE) || ($type == EU_DATE_RANGE)) {
			$u= _timify($u, $type);
			$l= _timify($l, $type);
		}
		
		my $result = _greater_than($u, $var, $self->{$state}->{upper_inclusive})
			+ _greater_than($var, $l, $self->{$state}->{lower_inclusive});
		
		return $state if $result;

	}
	return 0;
}

sub _greater_than {
	my ($a, $b, $inc) = @_;  	# first, second elements, and operator type
					# returns 1 if true, -1 if false
	if ($inc) { return 1 if $a >= $b;
	} else { return 1 if $a > $b; }
	return -1;
}


sub _timify {
	my ($u, $type) = @_;
	
	require Date::Calc;

	if ($type == EU_DATE_RANGE) {
		$u = Date::Calc::Date_to_Days(Date::Calc::Decode_Date_EU($u));
	} else {
		$u = Date::Calc::Date_to_Days(Date::Calc::Decode_Date_US($u));
	}
	
	
	return $u;	
}





=head1 NAME

Set::Range - Easy conditional operations on a set of ranges.

=head1 SYNOPSIS

	use Set::Range;

	my %set= ('1' => { 	lower => 0,
				upper => 10,
				upper_inclusive => 1,
			},
	    	  '2' => { 	lower => 11,
				upper => 100,
				lower_inclusive => 1,
			 },
		);

	my $range=Set::Range->new(\%set); print $range->getSet('19', NUM_RANGE); 
	# prints "2"



	my %set= ('Jan' => { 	lower => '1/1/2001',
				upper => '1/31/2001',
				upper_inclusive => 1,
				lower_inclusive => 1,
			}, # Days in January
	    	  'Feb' => { 	lower => '2/1/2001',
				upper => '2/28/2001',
				upper_inclusive => 1,
				lower_inclusive => 1,
			 }, # Days in February
		);

	my $range=Set::Range->new(\%set);

	print $range->getSet('1/11/2001', DATE_RANGE);
	# prints "Jan"



=head1 INSTALLATION

   perl Makefile.PL
   make
   make test
   make install

Win32 users substitute "make" with "nmake" or equivalent. 
nmake is available at http://download.microsoft.com/download/vc15/Patch/1.52/W95/EN-US/Nmake15.exe

=head1 DESCRIPTION

Set::Range allows you to define ranges of numeric or date values and will
return the set that a given test value lies in. This module removes the
need for multiple if .. elsif .. (etc) tests and lets you modify the sets
on the fly without having to recode the logic in your scripts.

E.g.: define date ranges and test for which set '1/1/2002' is in. 

=head2 METHODS

=over 4

=item new

This creates the Set::Range Object

Example:
    my $range = Set::Range->new(\%sets);

    Pass C<new()> a reference to a Hash containing the set
    information.
    
    
=over 6

=item %sets

  The hash defining the sets contains one hash per set
  with at least 'upper' and 'lower' defined.
  'upper_inclusive' and 'lower_inclusive' are optional
  and are the equivalent of >= and <= for the upper and 
  lower set boundries.

  The set hash can look like this:
  
  { 
    'key1' => { 
  		lower => 0,
  		upper => 10
  		},
    'key2' => {
    		lower => 10,
    		upper => 15,
    		lower_inclusive => 1,
    	      },
    'key3' => {
    		lower => 15
    		upper => 25,
    		lower_inclusive => 1,
    		upper_inclusive => 1,
    	      },
   }
  
  etc... The lower and upper values can either be
  numeric values or date values in the form
  mm/dd/yyyy or dd/mm/yyyy (see C<getSet> for
  Euro-formatted dates)
  
=back

=item getSet

C<getSet()> returns the value of the set that the test item is a member of.
Optionally accepts one of the following contants (defaults to numeric):
NUM_RANGE, DATE_RANGE, EU_DATE_RANGE, TIME_RANGE(same as NUM_RANGE)

Examples:

    my $set = $range->getSet(10);
    my $set = $range->getSet('1/14/2002', DATE_RANGE);


getSet returns 0 if the test value was not found to be a member of any 
set.

Note: Set::Range uses Date::Calc functions to convert the date to
a datestamp. I settled on Date::Calc because Time::Local doesn't
support years > 2038.

=head1 EXPORT

NUM_RANGE, DATE_RANGE, EU_DATE_RANGE, TIME_RANGE constants

=head1 BUGS & REQUESTS

Please let me know!

=head1 SEE ALSO

Date::Calc

=head1 AUTHOR

S. Flack : perl@simonflack.com

=cut
