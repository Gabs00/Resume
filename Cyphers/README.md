Created by: Gabs00

Still work to be completed on this, need to add the Vernam Cypher, also will spend time refactoring all the code.

```perl

#####################
#	USAGE	    #
#####################
my $vig = Vigenere->new(phrase => 'flying');     #create Vigenere class, phrase is required

my $text = "Hello"; $vig->text($text);           #sets the text to be de/encrypted
my $from = $vig->text($text);

my @list = qw/ hi there sally/;
$vig->from_array("stuff", @list);               #First argument can be a string, second a list. useful for line
                                                #by line reading from a file, appends to an array. set the first param 
                                                #to undef if not using.

print $vig->crypto();                           #prints the encrypted string that has been set with text.

print $vig->crypto($from, 1), "\n";             #first argument for, text to be en/decrypted, second argument is mode, 1
                                                #for decryption.

$vig->key(5);                                   #ceasar cypher can be used as well
print $vig->Ceasar::cypher("abc\n");            #Vigenere class overrides ceasars cypher method


```
