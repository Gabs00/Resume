#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use XML::Simple qw(:strict);
use Data::Dumper;
use Ingredient;






my $key = "yas6vg4wwgqdaky4ht2pkrh4";
my $query = "salt";
my $results = getItem($key,$query);

my @keys = keys %{ $results->{'items'}->{'item'} };

my %first = %{ $results->{'items'}->{'item'}->{$keys[0]} };
my $salt = Ingredient->new(
			itemId => $keys[0],
			name => $first{'name'},
			brandName => $first{'brandName'},
			price => $first{'salePrice'},
			sizeUnit => 'oz',
			image => $first{'mediumImage'},
			Link => $first{'productUrl'},			
);

print $salt->name, "\n";



sub getItem {
	my ($key, $query) = @_;
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
}
