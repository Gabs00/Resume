#!/usr/bin/perl

#questionable whether this needs its own class, we will see, if it only contains fields and no subroutines.

package Ingredient;

use Moose;
use namespace::autoclean;

has itemId => (
	is => 'rw',
	isa => 'Int',
	required => 1,
);

has name => (
	is => 'rw',
	isa => 'Str',
	required => 1,
);

has brandName => (
	is => 'rw',
	isa => 'Str',
);

has msrp => (
	is => 'rw',
	isa => 'Num',
);

has price => (
	is => 'rw',
	isa => 'Num',
	required => 1,
);

has size => (
	is => 'rw',
	isa => 'Num',
);

has sizeUnit => (
	is => 'rw',
	isa => 'Str',
	required => 1,
);

has image => (
	is => 'rw',
	isa => 'Str',
	required => 1,	
);

has Link => (
	is => 'rw',
	isa => 'Str',
	required => 1,
);

#price per unit
has ppu => (
	is => 'rw',
	isa => 'Num',
	lazy => 1,
	builder => '_calc_ppu',
);

sub _calc_ppu {
	my $self = shift;
	
	my $ppu = ($self->price / int($self->size));
	$ppu = int($ppu*1000);
	$ppu/=1000;
	
	return $ppu;
}
1;
