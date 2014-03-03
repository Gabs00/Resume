#!/usr/bin/perl


package Ingredient;

use Moose;
use namespace::autoclean;
use Measurements;

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

has grams => (
	is => 'rw',
	isa => 'Num',
	lazy => 1,
	builder => '_build_grams',
);

#price per unit
has ppu => (
	is => 'rw',
	isa => 'Num',
	lazy => 1,
	builder => '_calc_ppu',
);

has ppg => (
	is => 'rw',
	isa => 'Num',
	lazy => 1,
	builder => '_calc_ppg',
);

has category => (
	is => 'rw',
	isa => 'ArrayRef',
	default => sub {[]},
);

sub update {
	my $self = shift;
	$self->grams($self->_build_grams);
	$self->ppg($self->_calc_ppg);
	$self->ppu($self->_calc_ppu);
}

sub _build_grams {
	my $self = shift;
	my $mes = Measurements->new();
	my $size = $self->size;
	my $unit = $self->sizeUnit;
	return $mes->to_grams($size, $unit, 'wet');
}

sub _calc_ppg {
	my $self = shift;
	my $ppg = ($self->price/$self->grams);
	$ppg = int($ppg*1000);
	$ppg/=1000;
	
	return $ppg;
}
sub _calc_ppu {
	my $self = shift;
	
	my $ppu = ($self->price /$self->size);
	$ppu = int($ppu*1000);
	$ppu/=1000;
	
	return $ppu;
}
1;
