#!/usr/bin/perl

use strict;
use warnings;
use LWP::Simple;
use HTML::Parser;
use Data::Dumper;

my $content;
my @links;
my %toCSV;
#craigslist URL
my $url= "http://atlanta.craigslist.org/search/reb?" .
		 "zoomToPosting=&catAbb=reo&query=&minAsk=&maxAsk=&b" .
         "edrooms=3&housing_type=6&hasPic=1&excats=";
		 
#craigslist domain
my $domain = "http://atlanta.craigslist.org";
my $p = HTML::Parser->new( api_version => 3);

print "Getting craigslist content.\n\n";

$content = get($url) or die($!);
print "Done.\nParsing Content";

#sets first open tag handler to find listings.
$p->handler(start => \&findListings, 'self, attr, attrseq, text' );
$p->parse($content);

print "Done parsing content, found " . @links . " listings.",
	"\nParsing Listings";

#This does all the magic, preparing a hash to be exported to CSV.
my $link;
my @flag = (0, 0);
$p->handler(start => \&getInfo, 'self, attr, attrseq, text');
$p->handler(text =>\&parseText, 'self, attr, attrseq, text');
$p->handler(start_document => \&startD);

my $counter = 0;
while($link = shift(@links)){
	print $link, "\n";
	$content = get($domain . $link) or die "$!";
	$p->parse($content);
}


$p->parse($content);

#filename, will be in current folder
my $doc = 'test.csv';

#openning filehandle
open (my $fh, '>', $doc) or die "Could not create file: $!";

#setting up the fields:
my @fields = qw//;

for my $key(keys %toCSV){
	print { $fh } $key, ",";
	for my $secKey (keys %{ $toCSV{$key} }){
		if(ref($toCSV{$key}->{$secKey}) eq 'Array'){
			print Dumper $toCSV{$key}->{$secKey};
		}
	}
	print "\n";
}


#parses all tags in HTML document retrived.
#finds tags with href and pushes them into the links array.
sub findListings {

	my ($self, $attr, $attrseq, $text) = @_;
	if(defined($attr->{'href'}) && $attr->{'href'} =~ /\w+\/\w+\/\d+/g){
		push @links, $attr->{'href'};
	}
}

#this gets the relevant info for each listing, 
#addr, reply email, google maps link, all text in body.
sub getInfo {
	my ($self, $attr, $attrseq, $text) = @_;
	
	#gets images and puts them into an array
	if($attr->{'src'} && $attr->{'src'} =~ /images/){
		push @{ $toCSV{$link}{'images'} }, $attr->{'src'};
	}
	elsif($attr->{'href'} && $text =~ /(maps\.google)/ ){
		$toCSV{$link}{'map'} = $attr->{'href'};
	}
	elsif($attr->{'class'} && $attr->{'class'} eq 'mapaddress' && $text =~ /(div)/){
		$flag[0] = 1;
	}
	elsif($attr->{'id'} && $text =~ /(postingbody)/){
		$flag[1] = 1;
	}
	elsif($attr->{'href'} && $text =~ /reply/){
		my @info = ( "Not", "yet", "implimented", "intentionally");
		for my $infos (qw/preferred name phone email/){
			$toCSV{$link}{$infos} = shift @info;
		}

	}
}



sub parseText {
	my ($self, $attr, $attrseq, $text) = @_;	
	if($flag[0]){
		$toCSV{$link}{'addr'} = $text;
		$flag[0] = 0;
	}
	elsif($flag[1]){
		push @{ $toCSV{$link}{'body'} }, $text;
		$flag[1] = 0;
	}
}

sub startD {
	$counter++;
	print "Processing listing $counter\n";
}
=TODO, impliment this
sub getContacts {
	my $contact = "http://atlanta.craigslist.org" . $text;;
	$cContent = get($contact);
	my $cP = HTML::Parser->new( api_version => 3);
}
=cut
