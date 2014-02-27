#!/usr/bin/perl

use Modern::Perl;
use Plate;
use Tk;

my $VERSION = 0.00;

my $win = new MainWindow;

#Arbitrary dimensions like a boss
$win->geometry("1200x800");
$win->configure(-menu => my $menubar = $win->Menu() );

MainLoop;
