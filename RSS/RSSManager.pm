#!/usr/bin/perl
package RSSManager;
use Moose;
use namespace::autoclean;
use strict;
use warnings;
use Feed;
use Data::Dumper;

has saveFile => (
	is => 'rw',
	isa => 'Str',
	default => 'feed.list',
);
has feedList => (
	is => 'rw',
	isa => 'ArrayRef',
	builder => '_get_feed_list',
	lazy => 1,
);

has URL => (
	is => 'rw',
	isa => 'ArrayRef',
	predicate => 'has_url',
);


has feeds => (
	traits => ['Array'],
	is => 'rw',
	isa => 'ArrayRef',
	builder => '_get_feed_list',
	lazy => 1,
	handles => {
		add_url => 'push',
		shift_url => 'shift',
		pop_url => 'pop',
	},
);



has RSS => (
	is => 'rw',
	isa => 'Feed',
	lazy => 1,
	builder => 'load_feed',
);

#Loads actual RSS feed
sub load_feed {
	my $self = shift;
	my @temp;

	if(!defined($self->URL)){
		if(defined($self->feed)){
			@temp = $self->shift_url;
			$self->URL(\@temp);
		}
	}
	else {
		return Feed->new(feedUrl =>$self->URL->[0], atom =>$self->URL->[1]);
	}
}


sub save_feed {
	my $self = shift;
	$self->add_url($self->URL);	
	open (my $fh, '>', $self->saveFile) or ERROR($!);
	my @items = @{ $self->feeds };
	for my $item (@items){
		next unless $item;
		print { $fh } $item->[0], ' ', $item->[1], "\n";
	}
}
sub add_feed {
	my $self = shift;
	my $atom = $_[0] || 0;

	if($self->has_url && defined($self->URL)){
		my @temp = ($self->URL, $atom);
		$self->add_url(\@temp);
	}
}
sub update_list {
	my $self = shift;
	return $self->_get_feed_list();
}

sub _get_feed_list {
	my $self = shift;
	if (-e $self->saveFile){
		open (my $fh, "<", $self->saveFile) or ERROR($!);
		my @list;
		while(<$fh>){
			chomp;
			my @temp = split ' ';
			push @list, \@temp;
		}
		return \@list;
	}
	return [];
}

sub ERROR {
	my $e = shift;
	die $e;
}

1;
