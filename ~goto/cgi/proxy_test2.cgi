#!/usr/bin/perl --

use LWP::UserAgent;

my $ua = LWP::UserAgent->new;
$ENV{'HTTP_PROXY'} = 'http://proxy.ise.shibaura-it.ac.jp:10080';
$ua->env_proxy;

my $req = HTTP::Request->new(GET => 'http://www.google.com/');
print $ua->request($req)->as_string;
