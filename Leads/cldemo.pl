#!/usr/bin/perl
=ABOUT
	Created by: Gabar
	Date: 2/24/2014
	Notes: 
	*This was quickly put together to show a program designed to get leads in real estate. 
	*It only shows 3 bedroom listings posted by owner, though realtors are also using this so results vary
	
	*Much more can be added to this program
	Examples: 
		*Keyword search
		*Different types of houses
		*Gallery for images
		*GUI to show each listing
		*Auto email responding / Bulk email sending
		*SQL Database that allows quick searching
		*Anything you can think of
	
	Contact: gewen87@gmail.com
=cut
use strict;
use warnings;
use LWP::Simple;
use HTML::Parser;
use Data::Dumper;
use Class::CSV;

my $content;	#Will contain the scripts content after get() from craigslist
my @links;	#All listings
my %toCSV;	#Holds all info until ready to format for csv output

#Craigslist URL, 3br by owner
my $url= "http://atlanta.craigslist.org/search/reb?" .
	 "zoomToPosting=&catAbb=reo&query=&minAsk=&maxAsk=&b" .
         "edrooms=3&housing_type=6&hasPic=1&excats=";

#Craigslist domain
my $domain = "http://atlanta.craigslist.org";

my $p = HTML::Parser->new( api_version => 3);

print "Getting craigslist content.\n\n";

#Get our data from craigslist
$content = get($url) or die "Could not get $url: $!";

print "Done.\nParsing Content";

#Sub findListings puts all links to listings in @links array
$p->handler(start => \&findListings, 'self, attr, attrseq, text' );

#Parses $content, running findListings on all opening tags
$p->parse($content);

print "Done parsing content, found " . @links . " listings.",
	"\nParsing Listings.\n";

#This does all the magic, preparing a hash to be exported to CSV.
my $link;

#Flag is used to activate parseText.
my @flag = (0, 0);

#getInfo, gets needed info from tags and puts in toCSV
#parseText gets listing info
$p->handler(start => \&getInfo, 'self, attr, attrseq, text');
$p->handler(text =>\&parseText, 'self, attr, attrseq, text');

my $counter = 0;

#Iterates through all links, getting the link and then parseing it with above handlers.
while(($link = shift(@links))){
	if(!defined($toCSV{$link})){
		$counter++;
		$toCSV{$link}{'link'}= $domain . $link;
		print "Processing listing $counter, $link\n";
		$content = get($domain . $link) or die "$!";
		$p->parse($content);
	}
	else {
		print "$link, is a duplicate\n";
	}
}

#Setting up CSV with columns
my @keys = ("addr", "body", "preferred", "email","link", "map");
my $csv = Class::CSV->new(
	fields => \@keys,
);

#Parses each listing in %toCSV into an array in the correct order
for my $link (keys %toCSV){
	my @temp = expand($toCSV{$link},$link, \@keys);
	
	#Adds formatted array to CSV
	$csv->add_line(@temp);
}

print "Processing Complete.\n";

#Filename, will be in current folder, defaults to opening with excel
#Not if you have the file open, it will not save to this file
my $doc = 'test.csv';

#openning filehandle
open (my $fh, '>', $doc) or die "Could not create file: $!";


print "Saving File.\n";

#First out is the fields
print {$fh} "Address, Post Body, Preferred Contact, Email, Link, Map Link\n";

#Then all the data
print {$fh} $csv->string();

print "file saved to $doc\n";

############################
	#SUBROUTINES#
############################

#Parses all tags in HTML document retrieved.
#Finds tags with href and pushes them into the links array.
sub findListings {

	my ($self, $attr, $attrseq, $text) = @_;
	if(defined($attr->{'href'}) && $attr->{'href'} =~ /\w+\/\w+\/\d+/g){
		my $found = grep { $attr->{'href'} eq $_} @links;		#Making sure there are no duplicates
		push @links, $attr->{'href'} unless $found;
	}
}

#This gets the relevant info for each listing, 
#addr, reply email, google maps link, all text in body.
sub getInfo {
	my ($self, $attr, $attrseq, $text) = @_;


	if($attr->{'href'} && $text =~ /(maps\.google)/ ){
		$toCSV{$link}{'map'} = $attr->{'href'};
	}
	elsif($attr->{'class'} && $attr->{'class'} eq 'mapaddress' && $text =~ /(div)/){
		$flag[0] = 1;
	}
	elsif($attr->{'id'} && $text =~ /(postingbody)/){
		$flag[1] = 1;
	}
	elsif($attr->{'href'} && $text =~ /reply/){
			   my $newLink = $attr->{'href'};
			   getContact($newLink);
	}
}


#If the corresponding flag is set, gets the text body or address
sub parseText {
	my ($self, $attr, $attrseq, $text) = @_;	
	if($flag[0]){
		$toCSV{$link}{'addr'} = $text;
		$flag[0] = 0;
	}
	elsif($flag[1]){
		$toCSV{$link}{'body'}= $text;
		$flag[1] = 0;
	}
}


#When a reply link is found, spawns a new get request and a new parser
#to parse the reply page
sub getContact {
	my $newLink = shift;
	my $p = HTML::Parser->new(api_version => 3);
	$p->handler(text => \&getContactInfo, 'self, attr, attrseq, text');
	my $content = get($url . $newLink) or die "$!";
	$p->parse($content);
}

#Not yet correctly implimented, will if job offer is made
sub getContactInfo {
	my ($self, $attr, $attrseq, $text) = @_;
	chomp($text);
	$text =~ s/(\r\n)|\s+//g;
	if($text =~ /\@/ ){
		$toCSV{$link}->{'email'}= $text;
	  }
}

#This sub takes in a listing as a hash
#The link
#And the know keys and makes an array with that data
#returns an array ref with the data ready to be sent to CSV
sub expand {
	my %hash = %{ $_[0] };
	my $link = $_[1];
	my @keys = @{ $_[2] };
	my @temp;
	for my $key(@keys){
		my $info;
		if (defined($hash{$key})){
			$info = $hash{$key};
		}
		else {
			$info = 'N\A';
		}
		$info =~ s/(\r\n)|(\r+)|(\n+)|(\t)//g;
		push @temp, $info;
	}
	return \@temp;
}
