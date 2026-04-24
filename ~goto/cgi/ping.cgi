#!/usr/bin/perl
use Net::Ping;

my $host = 'www.google.com';


my $p = Net::Ping->new("icmp");
my $result = $p->ping($host, 2);


print "Content-Type: text/html; charset=UTF-8\n\n";
if($result){
 print "$host is alive!\n";
}