#!/usr/bin/perl

use Modern::Perl;
use Data::Dumper;
use Plate;


my $plate = Plate->new();
my $query = "salt";

my $recipe = Recipe->new(recipeName => "Cookies", servings => 4, ingredients => {
								'flour' => [2, 'cups'],
								'salt' => [2, 'Tbsp'],
								'milk' => [.5, 'cups'],
								});


$recipe->price(20);

print "Price \$",$recipe->price,"\nPrice per serving: \$",$recipe->pricePerServing, "\n"; 

=Ingredients Testing
my $results = $plate->getItem($query);

my @keys = keys %{ $results->{'items'}->{'item'} };

my %first = %{ $results->{'items'}->{'item'}->{$keys[3]} };

#checks if size is defined, if not, the info is contained in name
my $containSize = defined($first{'size'}) ? $first{'size'}:$first{'name'};

my ($size, $unit) = $plate->getSize($containSize);
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
