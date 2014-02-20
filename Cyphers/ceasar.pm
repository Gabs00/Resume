#!/usr/bin/perl

package Ceasar;
use Moose;
use namespace::autoclean;

#method Ceaser->cypher takes 2 arguments, string to be translated, and mode.
#0 to decrypt
#1 to encrypt

has key =>(
	is => 'rw',
	isa => 'Int',
	required => 1,
);

has alpha_map => (
	is => 'ro',
	isa => 'HashRef',
	builder => 'get_map',
);

has alpha => (
	is => 'ro',
	isa => 'ArrayRef',
	builder => 'get_alpha',
);

#A flag used to determine whether the character was upper case.
#Doessn't need to be a object member, but this happened when troubleshooting another
#need to revert this change
has case => (
	is => 'rw',
	isa => 'Bool',
	default => '0',
);

#Used to shift alphabet and make new arrays later
#I've seen this solved aqs an equation, but I like showing it this way
#seems so much clearer than a = n(n+1) (<= not actual formula)
sub get_alpha {
	return ['a' .. 'z', 'a' .. 'z'];
}

sub get_map {
	my @array = ('a' .. 'z');
	my %hash;
	for my $i (0..$#array){
		$hash{$array[$i]} = $i; 
	}
	return \%hash;
}

#Magic occurs here
sub cypher {
	my $self = shift;
	my ($key, $phrase) = ($self->key, $_[0]);
	my $encrypt = $_[1] || 0;
	my $alpha = $self->alpha;
	my $alpha_map = $self->alpha_map;
	my @newPhrase;
	my @temp = split '', $phrase;
	for my $index(0 .. (@temp-1)){

		if($temp[$index] =~ /[a-zA-Z]/){
			if($encrypt){
				$self->UppLow($temp[$index]);

				#For char at index $index
				#Find the index of char at $index in the alpha_map hash
				#Add that index to the key.
				#The char is now the new char at the new index in $alpha ('a'..'z', 'a'..'z')
				my $pushVal = $alpha->[($alpha_map->{lc($temp[$index])}+$key)];
				$pushVal = uc($pushVal) if $self->case;
				push @newPhrase, $pushVal;
				$self->case(0);
			}
			else{
				$self->UppLow($temp[$index]);

				#same as above but instead you subtract the key from the 
				#index
				my $pushVal = $alpha->[($alpha_map->{lc($temp[$index])}-$key)];
				$pushVal = uc($pushVal) if $self->case;
				push @newPhrase, $pushVal;
				$self->case(0);
			}
		}
		else {
			push @newPhrase, $temp[$index];
		}
	}

	return join '', @newPhrase;
}

sub UppLow {
	my ($self, $char) = @_;

	if($char =~ /[A-Z]/){

		$self->case(1);
	}	
	else {
		$self->case(0);
	}
	return 1;
}

1;
