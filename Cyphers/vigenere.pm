#!/usr/bin/perl

package Vigenere;
use Moose;
use namespace::autoclean;
extends 'Ceasar';
#this class overrides Ceasars key and cypher

#encrypting:
#Get index of char in phrase at key 0, 
#get index of char to be encypted, that is the new key
#Go to index of char from phrase
#decrypting
#use cypher of phrase
#go to position of char to be decrypted
#take index and use as index on key = 0 cypher
has key =>(
	is =>'rw',
	isa=>'Int',
	default => 0,

);
has phrase => (
	is => 'rw',
	isa => 'Str',
	required => 1,
);

has vTable => (
	is => 'ro',
	isa => 'ArrayRef',
	lazy => 1,
	builder => '_build_cyphers',
);

has text => (
	is => 'rw',
	isa => 'Str',
	default => '',
	clearer => 'clear_text',
);

#Allows you to append to the text member
sub from_array{
	my ($self, $text, @array) = @_;
	if(!defined($self->text)){
		$self->text('');
	}
	if(defined($text)){
		$self->text($self->text . $text);
	}
	if(@array){
		for my $i(0 .. $#array){
			$self->text($self->text . $array[$i]);
		}
	}
	return 1;
}


#Makes Viginere table, each element of @cyphers is a ceaser cypher where each letter
#of the alphabet is starting at index 0.
 
sub _build_cyphers{
	my $self = shift;
	my @maps = @{ $self->alpha };
	my $max = 25;
	my @cyphers;
	for my $i(0 .. 25){
		my @array = @maps[$i..($i+$max)];
		push @cyphers, \@array;
	}

	return \@cyphers;
}

#Gets the index of a character, where it starts in the alphabet with index of a = 0.
sub get_position {
	my $self = shift;
	my $charPhrase = shift;
	my $index = $self->alpha_map->{$charPhrase};
	return $index;
}
#Gets the ceaser cypher for provided character where index char = 0
sub get_enc_cypher{
	my $self = shift;
	my $char = shift;
	my $index = $self->alpha_map->{lc($char)};
	my $shifted = $self->vTable->[$index];
	return $shifted;
}

#Takes a ceaser cypher and reverses the the index value positions
sub cypher_map {
		my (@cypher) = @{ $_[0] };
		my %hash;
		for my $i(0.. $#cypher){
			$hash{$cypher[$i]} = $i;
		}
		return \%hash;
}
#Returns the encrypted character
sub get_char {
	my ($self, $charPhrase, $charEnc) = @_;
	my $index = get_position($self, $charPhrase);
	my $cypher = get_enc_cypher($self, $charEnc);
	my $letter = $cypher->[$index];
	return $letter;
}

#Returns the decrypted character
sub get_de_char{
		my ($self, $charPhrase, $charDec) = @_;
		my $cypher = get_enc_cypher($self, $charPhrase);
		my $cypher_map = cypher_map($cypher);
		my $index = $cypher_map->{lc($charDec)};
		my $letter = $self->alpha->[$index];
		return $letter;
}

#This method prepares the text provided and the keyword for en/decryption
#makes an AoA containing the char to encrypt and the char from the keyword
#this is mainly to be able to skip punctuation and numbers
sub prepare_info {

	my $self = shift;
	if(!defined($self->text)){
		return;
	}
	my $phrase = $self->phrase;
	my $text = $self->text;
	my @count = $text =~ /([a-zA-Z])/g;
	my @phraseArray;
	for my $i (0 .. $#count){
		my @phraseList = split('', $phrase);
		for(@phraseList){
			push @phraseArray, lc($_);
		}

	}
	my @textMap;
	my @textArray = split('', $text);
	for(@textArray){
		if(/[a-zA-Z]/){
			my $char = shift(@phraseArray);
			push @textMap, [$_, $char];
		}
		else {
			push @textMap, [$_,$_];
		}
	}

	return \@textMap;
}

sub crypto {
	my $self = shift;
	my $string = shift;
	my $decrypt = $_[0] || 0; 
	if(defined($string)){
		$self->text($string);
	}
	my $data = prepare_info($self);
	my $count = scalar(@{ $data });
	my $text = '';
	for my $i(0 .. ($count - 1)){
		$text.=cypher($self, $data->[$i], $decrypt);
	}
	return $text;
}

#This sub probably needs to be refactored, it puts everything together.
sub cypher {
	my $self = shift;
	my ($char, $phrase) = @{ $_[0] };
	my $decrypt = $_[1] || 0;
	my $newChar;
		if($char =~ /[a-zA-Z]/){
			if(!$decrypt){
				$self->UppLow($char);
				my $pushVal = get_char($self, $phrase, lc($char));

				if($self->case){
					$newChar = uc($pushVal);
				}
				else{
					$newChar = $pushVal;
				}

				$self->case(0);
			}
			else{
				my $pushVal = get_de_char($self, $phrase, lc($char));

				if($self->case){
					$newChar = uc($pushVal);
				}
				else{
					$newChar = $pushVal;
				}

				$self->case(0);
			}
		}
		else {
			$newChar = $char;
		}

	return $newChar;
}
1;
