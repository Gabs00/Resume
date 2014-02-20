#!/usr/bin/perl

package Feed;
use Moose;
use namespace::autoclean;
use XML::Simple qw(:strict);
use LWP::Simple;

has feedUrl => (
	is => 'rw',
	isa => 'Str',
	required => 1,
);
has atom => (
	is => 'ro',
	isa => 'Bool',
	default => 0,
	required => 1,
);
has feed => (
	is => 'ro',
	isa => 'HashRef',
	builder => '_get_feed',
	lazy => 1,
);

has categories => (
	is => 'ro',
	isa => 'ArrayRef',
	builder => '_set_cats',
);

has items => (
	is => 'ro',
	isa => 'ArrayRef',
	lazy => 1,
	builder => '_get_items',
);

sub _get_items {
	my $self = shift;
	if(!defined($self->feed)){
		$self->update();
	}
	my @cats = @{ $self->categories };
	return $self->feed->{$cats[0]}{$cats[2]};
}

sub _set_cats {
	my $self = shift;

	if($self->atom){
		die('ATOM FEEDS NOT CURRENTLY SUPPORTED');
		return ['feed', 'subtitle', 'entry'];
	}
	else {
		return ['channel', 'description', 'item'];
	}
}


sub update {
	my $self = shift;
	$self->feed($self->get_feed);
}
sub _get_feed {
	my $self = shift;
	my @cats = @{ $self->categories };
	my $content = get($self->feedUrl) or ERRORS($!);
	my $xml = XML::Simple->new();
	if($content){
		return $xml->XMLin($content, KeyAttr => $cats[0], ForceArray =>[$cats[2]]);
	}
	else {
		return {undef => $!};
	}
}

#for error handling when attached to GUI
sub ERRORS {
	my $error = shift;
	print "Could not open: $!";
}

1;
