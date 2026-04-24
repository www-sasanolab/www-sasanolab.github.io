#!/usr/bin/perl --

#use strict;
#use warnings;
use CGI;
#use LWP;
use HTTP::Request;
#use XML::Simple;

my $appid = 'HAT0Veexg643G0kKK7KQWZRrHEsp.WiP_adgFJI1nbnUz0pAl1gwSRqqr4ipPPU-'; 
my $CHIE_SEARCH_API_HOST  = 'chiebukuro.yahooapis.jp';
my $CHIE_SEARCH_API_URL   = '/Chiebukuro/V1/questionSearch';
my $CHIE_SEARCH_API_APPID = $appid;

my $cgiObj = new CGI;
#my $script_name = ($ENV{'SCRIPT_NAME'} =~ m|/([^/]*)$|)[0];

print "Content-type: text/html\n\n";
print "aaa";
exit 0;