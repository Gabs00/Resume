package Plate;
use Moose;

use Ingredient;
use Recipe;
use XML::Simple qw(:strict);
use LWP::UserAgent;

#if you fork this Repo, or use my code, please do not use my API key.
#Walmart is giving them away.
#https://developer.walmartlabs.com/

has key => (
	is => 'ro',
	isa => 'Str',
	default => 'yas6vg4wwgqdaky4ht2pkrh4',
);

sub getItem {
	my $self = shift;
	my $key = $self->key;
	my $query = shift;
	my $search = "http://api.walmartlabs.com/v1/search?apiKey=" . $key ."&query=". $query .
					"&format=XML&sort=relevance&responseGroup=full";
	my $ua = LWP::UserAgent->new();
	my $response = $ua->get($search);
	my $xml = XML::Simple->new();
	if($response->is_success){
		my $content = $xml->XMLin($response->decoded_content, keyAttr => 'itemId', forceArray => 0);
		return $content if defined($content);
	}
	else {
		print $response->status_line;
	}
	return 0;
}

#Sometimes there is no size field, so we have to improvise. Size seems to also show up in the name field
sub getSize {
	my $self = shift;
	my $name = shift;
	
	$name =~ /(\d+\s\w+)/;
	if(defined($1)){
		my $size = $1;
		my @toReturn = split(' ', $size);
		return wantarray ? @toReturn: $toReturn[0]; 
	}
	return wantarray ? (0,"0") : 0;
}
1;
