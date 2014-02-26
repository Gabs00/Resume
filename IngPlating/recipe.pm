#!/usr/bin/perl

package Recipe;

use Moose;


#todo, how does this class get the ingredient class? add a hashRef of them? need to think of a way for these 
#two to communicate, the 'interface' may pass the ingredients over.

#I think Recipe doesn't need to know about ingredients 


has recipeName => (
	is => 'rw',
	isa => 'Str',
	required => 1
);

has ingredients => (
	is => 'rw',
	isa => 'HashRef',
	required => 1,
);

has items => (
	is => 'rw',
	traits => ['Array'],
	isa => 'ArrayRef',
	lazy => 1,
	builder => '_get_items',
	handles => {
		add_item => 'push',
		remove_first => 'shift',
		remove_last => 'pop',
	},
);

has directions => (
	is => 'rw',
	isa => 'Str',
	default => 'Noy yet added',
	lazy => 1,
);

has servings => (
	is => 'rw',
	isa => 'Int',
	required => 1,
);

#price will be set by ingrediant
has price => (
	is => 'rw',
	isa => 'Num',
	default => 0,
	lazy => 1,
);

has pricePerServing => (
	is => 'rw',
	isa => 'Num',
	builder => 'get_pps',
	lazy => 1,
);


sub get_pps {
	my $self = shift;
	if($self->price > 0){
		my $pps = ($self->price/$self->servings);
		return $pps;
	}
	return 0;
}

sub _get_items {
	my $self = shift;
	my @temp;
	
	if(defined($self->ingredients)){
		@temp = keys %{ $self->ingredients };
		return \@temp;
	}
	
	return [];
};

1;
