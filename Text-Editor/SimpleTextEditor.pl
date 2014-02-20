#!/usr/bin/perl


#	Code by: Gabs00

	

use strict;
use warnings;
use Tk;
use TK::TextUndo;
use Tk::Dialog;


my $currentFile;

my $win = new MainWindow;
$win->geometry('600x800');

#VERY IMPORTANT FOR GETTING MENU TO WORK
#need to use configure or define when creating MainWindow
#can be tricky.
$win->configure(-menu => my $menubar = $win->Menu( ), -title => 'Simple Text Editor');

#Menubar items ie. file edit view etc bar 
#Cascade is the drop down menu
my $file = $menubar->cascade(-label => '~File', -tearoff => 0);		#tearoff is the ability to detach the menu,
									#defaults to 1
#my $edit = $menubar->cascade(-label => '~Edit', -tearoff => 0);	#Not yet implemented, questionable whether it 
									#ever will be

#Sets up the help about menu
#The -command is the action that will occur when the button / item is selected
my $help = $menubar->cascade(-label => '~Help', -tearoff => 0);
$help->command(-label => 'About', -command => \&about);

#Menu items for file menu
#FYI this can be done quick and easy with map, but we'll get there eventually.
#The index 0 = menu item name, index 1 = shortcut keys, index 2 = which char in name will be underlined
my %filemenu = (
	"new" => [qw/New Ctrl-n 0/],
	"open" => [qw/Open Ctrl-o 0/],
	"save" => [qw/Save Ctrl-s 0/],
	"saveA" => ["Save As", qw/Ctrl-a 1/],
	"close" => [qw/Close Ctrl-w 0/]
);



#This for overwrites the previous values in the hash filemenu
#This hash provides access to all the menu items, so that we have a 
#Handle to use if we need to change anything
for(qw/new open save saveA close/){
	$filemenu{$_} = menu_items($file, @{$filemenu{$_}});
}

#-scrollbars => 'se' puts a scrollbar east and south.
#Pack is required to get the text widget to show in the gui,
#expand => 1 fills the entire remaining space where the widget is located
#-side => bottom puts it under any other widgets in the same area.
#-fill => 'both' fills the entire allotment of -side, I think.
my $text = $win->Scrolled('TextUndo',
			-scrollbars => 'se')->pack(-fill => 'both',
					           -expand => 1,
						   -side => 'bottom'
						   );
#Events for once each button is used
#Configure is used to change properties of a widget after its
#creation.
$filemenu{'new'}->configure(-command => \&createNew);
$filemenu{'open'}->configure(-command => \&openFile);
$filemenu{'save'}->configure(-command => \&save);
$filemenu{'saveA'}->configure(-command => \&saveAs);
$filemenu{'close'}->configure(-command => \&exit);

#creating binding events for shortcut keys
$win->bind('Tk::TextUndo', '<Control-Key-n>',
			sub { createNew(); }
	);

$win->bind('Tk::TextUndo', '<Control-Key-o>',
			sub { openFile(); }
	);

$win->bind('Tk::TextUndo', '<Control-Key-s>',
			sub { save(); }
	);

$win->bind('Tk::TextUndo', '<Control-Key-a>',
			sub { saveAs(); }
	);

$win->bind('Tk::TextUndo', '<Control-Key-w>',
			sub { exit(); }
	);





MainLoop;

#############################
#Subroutines
#############################


#creates menu items
#takes a menu widget and list 
#returns a reference to a menu item
#note, doesn't need to be packed
sub menu_items {
	my $menus = shift;
	my ($label, $acc, $under) = @_;

	return $menus->command(
		-label => $label,
		-accelerator => $acc,
		-underline => $under
	);

}

#Clears text in main window
#clears current File so that there is not accidental file overwrites
sub createNew {
	my $choice = openDialog();
	if(defined($choice)){
		$text->delete('1.0', 'end');
		undef($currentFile);
	}
}


sub openFile {
	my $choice = openDialog();
	if(defined($choice)){
		my $file = $text->getOpenFile();
		if($file){
			$text->delete('1.0', 'end');
			open (my $fh, '<', $file) or die "Could not open file: $!";
			while(<$fh>){
				$text->insert('end', $_);
			}

			$currentFile = $file;
		}
	}
}


#Straight forward, makes a dialog box for whether
#you want to save the current file..
#for dialogs, don't need to pack, use Show.
#Show returns the button selected.
sub openDialog {
	my @items = ("Save","Save As","Discard");

	my $dialog = $win->Dialog(
		-title => 'Save current file?',
		-text => 'Save Current file?',
		-default_button => $items[0],
		-buttons => \@items,
	);

	my $button = $dialog->Show;

	if($button eq 'Save'){
		save();
	}
	elsif($button eq 'Save As'){
		saveAs();
	}

	return $button;
}
sub save {
	if ($currentFile){
		saveFile($currentFile);
	}
	else{
		saveAs();
	}
}

sub saveAs {
	my $file = $text->getSaveFile();
	saveFile($file);
}

sub saveFile {
	my $file = shift;
	if($file){
		open(my $fh, '>', $file) or die "Could not open save file: $!";
		print {$fh} $text->Contents();
		$currentFile = $file;
	}
}

sub about {
	my $about =$win->Dialog(
				-title => "About: Text Editor",
				-text => '',
				-buttons => ['ok'],
				);
	$about->configure(-text => "Program Name: Simple Text Editor\nCreated By: Gabs00\nDate: Feb. 12 2014");
	$about->Show;
}
