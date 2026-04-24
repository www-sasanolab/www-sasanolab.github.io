#!/usr/bin/perl
use strict;

my %mod_list;

listup($_) for grep {$_ ne '.'} @INC;
print "Content-Type: text/html; charset=UTF-8\n\n";
print "$_<br>\n" for sort keys %mod_list;

sub listup {

 my ($base, $path) = @_;
 (my $mod = $path) =~ s!/!::!g;

 opendir DIR, "$base/$path" or return;
 my @node = grep {!/^\.\.?$/} readdir DIR;
 closedir DIR;
 
 foreach (@node) {
  if (/(.+)\.pm$/) { $mod_list{"$mod$1"} = 1 }
  elsif (-d "$base/$path$_") { listup($base, "$path$_/") }
 }
}