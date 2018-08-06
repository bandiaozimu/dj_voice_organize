#! /usr/bin/perl

package smart_mv;


use 5.014;
use autodie;
#use LWP::Simple;
use utf8;
use Encode;
use Data::Dumper;
use File::Copy;
use File::Basename;
use Exporter;

our @ISA= qw( Exporter );

# these CAN be exported.
our @EXPORT_OK = qw( smart_move_in smart_rename );

# these are exported by default.
our @EXPORT =  qw( smart_move_in smart_rename );

my @suffix_list = ('.zip', '.rar', 'lzh');

sub smart_move_in {
    my $file   = $_[0];
    my $folder = $_[1];
    my ($i, $dash) = 1, '';
    my ($name, $path, $suffix) = fileparse($file, @suffix_list);
    while ( -e "$folder/$name$dash$suffix" ){ $dash = sprintf "-%d", $i++; }
    say "mv $file $folder/$name$dash$suffix";
    move "$file", "$folder/$name$dash$suffix";
}

sub smart_rename {
    my $file   = $_[0];
    my $new_name = $_[1];
    if( $file ne $new_name ){
        my ($i, $dash) = 1, '';
        my ($name, $path, $suffix) = fileparse($new_name, @suffix_list);
        while ( -e "$new_name$dash$suffix" ){ $dash = sprintf "-%d", $i++; }
        say "mv $file $new_name$dash$suffix";
        rename "$file", "$new_name$dash$suffix";
    }
}

1;
