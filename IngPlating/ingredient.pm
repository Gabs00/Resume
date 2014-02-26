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

1;
