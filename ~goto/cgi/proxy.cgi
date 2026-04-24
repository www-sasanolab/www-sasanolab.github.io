#! /usr/bin/perl
 use LWP::UserAgent;

 $ua = LWP::UserAgent->new;
 $ua->proxy(['http'] => 'http://proxy.ise.shibaura-it.ac.jp:10080');

 $req = HTTP::Request->new('GET',"http://www.google.com";);

 $res = $ua->request($req);
 print $res->content if $res->is_success;
