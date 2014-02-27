#!/usr/bin/perl

package Plate;
use Moose;

use Ingredient;
use Recipe;
use XML::Simple qw(:strict);
use LWP::UserAgent;
use File::Slurp;
use Data::Dumper;

#if you fork this Repo, or use my code, please do not use my API key.
#Walmart is giving them away.
#https://developer.walmartlabs.com/

#TO DO: allow indexing of save files so we don't have to slurp the whole file into memory
#This is partly in place with the short list

has key => (
	is => 'ro',
	isa => 'Str',
	default => 'yas6vg4wwgqdaky4ht2pkrh4',
);

has recipeList => (
	is => 'rw',
	isa => 'HashRef',
	default => sub {{}},
	lazy => 1,
);

has ingredientList => (
	is => 'rw',
	isa => 'HashRef',
	default => sub {{}},
	lazy => 1,
);

# This holds the item id numbers for ingredients, and the recipe name of recipes
has short => (
	is => 'rw',
	isa => 'HashRef',
	builder => '_make_short',
	lazy => 1,
);

has saveFiles => (
	is => 'rw',
	isa => 'ArrayRef',
	default => sub {['ingredients.xml','recipes.xml', 'short.xml']},
	lazy => 1,
);

has myXML => (
	is => 'ro',
	isa => 'XML::Simple',
	builder => '_xml',
	lazy => 1,
);

sub add_recipe {
	my ($self, $recipe) = @_;
	$self->recipeList->{$recipe->{'recipeName'}} = $recipe;
}

sub add_mult_recipe {
	my ($self, @recipes) = @_;
	
	for my $recipe(@recipes){
		$self->add_recipe($recipe);
	}
}

sub add_ingredient {
	my ($self, $ingredient) = @_;
	$self->ingredientList->{$ingredient->{'itemId'}} = $ingredient;
}

sub add_mult_ingredient {
	my ($self, @ingredients) = @_;
	for my $ingredient (@ingredients){
		$self->add_ingredients($ingredient);
	}
}

#Makes the shortened list of item names / ids
sub _make_short {
	my $self = shift;
	my @saveFiles = @{ $self->saveFiles };
	pop @saveFiles;
	my %list;
	for my $saveFile (@saveFiles){
		if(-e $saveFile){
			open (my $fh, '<', $saveFile) or die "Could not open save file: $!";
			
			while(my $line = <$fh>){
				
				#Keys names in the save files start with <opt>
				if($line =~ /\<opt\>/){						
					push @{ $list{$saveFile} }, $line;
				}
			}
			close $fh;
		}
		
		#checking if any extras were currently loaded in memory
		my %liveList = ($saveFile =~/(ingred)/ ) ? %{ $self->ingredientList } : %{ $self->recipeList };
		
		for my $key (keys %liveList){
			my $isPresent = grep { $key =~ /$_/ } @{ $list{$saveFile} };
			if(!$isPresent){
				push @{ $list{$saveFile} }, $key;
			}
		}
	}
	
	return \%list;
}

sub _xml {
	return XML::Simple->new();
}

#Saves the current lists of ingredients, recipes, and the short list
#Mode 0 = All lists
#Mode 1 = ingredient list
#Mode 2 = recipe list
#Mode 3 = short list
#Notice this bit of code is due to be replaced
sub save {
	my $self = shift;
	my $mode = shift || 0;
	my @toSave;
	
	#used to format the XML output.
	my @key = qw/itemId recipeName itemId/;												
	if($mode == 1 || !$mode){
		push @toSave, [ $self->saveFiles->[0], $self->ingredientList, $key[0]];
	}
	
	if($mode == 2 || !$mode){
		push @toSave, [$self->saveFiles->[1], $self->recipeList, $key[1]];
	}
	
	if($mode == 3 || !$mode){
		push @toSave, [$self->saveFiles->[2], $self->short, $key[2]];
	}
	
	while(my $save = shift(@toSave)){
	
		#_prep_save method converts the files to XML format,
		# second the key attribute
		my $xml = $self->_prep_save($save->[1], $save->[2]); 							
		open (my $fh, '>', $save->[0]) or die "failed to open " . $save->[0] . ": $!";  
		print { $fh } '<xml>', "\n";
		print { $fh } $_ for(@{ $xml });
		print { $fh } '</xml>';
	}
}

sub load_files {
	my $self = shift;
	my @files;
	my $xml = $self->myXML;
	my @key = qw/itemId recipeName itemId/;
	for my $fileName (@{ $self->saveFiles}){
		my $keyAttr = shift(@key);
		if(-e $fileName){
			my $toLoad = {$fileName => $xml->XMLin(join( '', read_file($fileName)), keyAttr => $keyAttr, forceArray => 0) };
			print Dumper $toLoad;
			$self->set_loaded($toLoad);													
		}
	}
}

#set_loaded determines which function to use when loading the files.
sub set_loaded {
	my $self = shift;
	my %loaded = %{ $_[0] };
	my ($key) = keys(%loaded);
	if($key =~ /ingred/){
		$self->_build_ingredient_list($loaded{$key}->{'opt'});
	}
	elsif($key =~ /recipe/){
		$self->_build_recipe_list($loaded{$key}->{'opt'});
	}
	elsif($key =~ /short/){
		$self->_build_short_list($loaded{$key}->{'opt'});
	}
}

sub _build_short_list {
	my $self = shift;
}

sub _build_recipe_list {
	my $self = shift;
	my @recipes; 
	if(defined($_[0])){
		@recipes = @{ $_[0]};
	}
	else {
		return 0;
	}
	print Dumper @recipes;
	while(my $key = shift(@recipes)){
		my %values = %{ shift(@recipes) };
		my $recipe = Recipe->new (
			recipeName => $key,
			servings => $values{'servings'},
			price => $values{'price'},
			description => $values{'description'},
			ingredients => $values{'ingredients'},
		);
		if(!@recipes){
			last;
		}
	}
}

sub _build_ingredient_list {
	my $self = shift;
	my @items;
	if(defined($_[0])){
		@items = @{ $_[0] };
	}
	else{
		return 0;
	}
	
	while(my $key = shift(@items)){
		
		my %values = %{ shift(@items) };
		my $entry = Ingredient->new(
			itemId => $key,
			name => $values{'name'},
			brandName => $values{'brandName'},
			price => $values{'price'},
			size => $values{'size'},
			sizeUnit => $values{'sizeUnit'},
			image => $values{'image'},
			Link => $values{'Link'},			
		);
		$self->ingredientList->{$key} = $entry;
		
		last unless @items;
	}
	
}

sub _prep_save {
	my $self = shift;
	my $toSave = shift;
	my $key = shift;
	my $xml = $self->myXML;
	my @temp;
	for(%{ $toSave }){
		push @temp, $xml->XMLout($_, keyAttr => $key);
	}
	
	return \@temp;
}

#Does a search for a user specified item against almarts search API
sub item_search {
	my $self = shift;
	my $key = $self->key;
	my $query = shift;
	my $search = "http://api.walmartlabs.com/v1/search?apiKey=" . $key ."&query=". $query .
					"&format=XML&sort=relevance&responseGroup=full";
	my $ua = LWP::UserAgent->new();
	my $response = $ua->get($search);
	my $xml = $self->myXML;
	if($response->is_success){
		my $content = $xml->XMLin($response->decoded_content, keyAttr => 'itemId', forceArray => 0);
		if (defined($content)){
			return $content->{'items'}->{'item'};
		}
	}
	else {
		print $response->status_line;
	}
	
	return 0;
}

#Sometimes there is no size field, so we have to improvise. Size seems to also show up in the name field
sub get_size {
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
