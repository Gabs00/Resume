#!/usr/bin/perl

package Measurements;
use Moose;

has conversions => (
	is => 'ro',
	isa => 'HashRef',
	builder => '_build_conversions',
);
sub _build_conversions{
	 my $self = shift;
	 my %measures;
	 my @keys = ("drop", "teaspoon", "tablespoon", "fluid ounce", "jigger", "gill",
				"cup", "pint", "fifth", "quart", "gallon", "pounds", "ounces");
	
	my @values = ((1/576), (1/6), (1/2), (1), (1.5), (4), (8), (16), (25.36), (32), (128), (16), (1));
	
	%measures = map {$_ => shift(@values) } @keys;
	return \%measures;
}

sub to_grams {
	my ($self, $amount, $measure, $type) = @_;
	my $ounces = $self->_to_ounces($amount, $measure);
	my $grams = $self->_ounces_to_grams($ounces, $type);
	return $grams;
}

sub to_measurement {
	my ($self, $amount, $measure, $type) = @_;
	my $ounces = _grams_to_ounces($amount, $measure);
	my $mes = _from_ounces($amount, $measure);
	return $mes;
}
sub _to_ounces {
	my ($self, $amount, $measure) = @_;
	my $factor = $self->conversions->{$measure};
	my $ounces = $amount * $factor;
	return $ounces;
}

sub _from_ounces {
	my ($self, $amount, $measure) = @_;
	my $divisor = $self->conversions->{$measure};
	my $converted = $amount / $divisor;
	return $converted;
}

sub _ounces_to_grams{
	my ($self, $ounces, $type) = @_;
	my $factor  = ($type eq 'dry') ? 28.35:29.57;
	my $grams = $ounces * $factor;
	return $grams;		
}

sub _grams_to_ounces{
	my ($self, $grams, $type) = @_;
	my $divisor = ($type eq 'dry') ? 28.35:29.57;
	my $ounces = $grams/$divisor;
	return $ounces;
}

1;
