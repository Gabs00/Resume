#!/usr/bin/perl

use Modern::Perl;
use LWP::UserAgent;
use XML::Simple qw(:strict);
use Data::Dumper;
use Ingredient;
use Recipe;






my $key = "yas6vg4wwgqdaky4ht2pkrh4";
my $query = "salt";

my $recipe = Recipe->new(recipeName => "Cookies", servings => 4, ingredients => {
															'flour' => [2, 'cups'],
															'salt' => [2, 'Tbsp'],
															'milk' => [.5, 'cups'],
													});


$recipe->price(20);

print "Price \$",$recipe->price,"\nPrice per serving: \$",$recipe->pricePerServing; 

=Ingredients Testing
my $results = getItem($key,$query);

my @keys = keys %{ $results->{'items'}->{'item'} };

my %first = %{ $results->{'items'}->{'item'}->{$keys[3]} };

#checks if size is defined, if not, the info is contained in name
my $containSize = defined($first{'size'}) ? $first{'size'}:$first{'name'};

my ($size, $unit) = getSize($containSize);
my $salt = Ingredient->new(
			itemId => $keys[0],
			name => $first{'name'},
			brandName => $first{'brandName'},
			price => $first{'salePrice'},
			size => $size,
			sizeUnit => $unit,
			image => $first{'mediumImage'},
			Link => $first{'productUrl'},			
);

print $salt->price, "\n", $salt->size, "\n", $salt->ppu,"\n";

=cut


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
	return 0;
}

#Sometimes there is no size field, so we have to improvise. Size seems to also show up in the name field
sub getSize {
	my $name = shift;
	
	$name =~ /(\d+\s\w+)/;
	if(defined($1)){
		my $size = $1;
		my @toReturn = split(' ', $size);
		return wantarray ? @toReturn: $toReturn[0]; 
	}
	return wantarray ? (0,"0") : 0;
}
