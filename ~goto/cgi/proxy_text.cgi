#!/usr/bin/perl

require('getHTTP');
($http_response, $errorMessage) = &getHTTP('http://www.google.com/');
#($http_response, $errorMessage) = &getHTTP('URL'=>'http://www.google.com/','Proxy'=>'proxy.ise.shibaura-it.ac.jp:10080');


print "Content-Type: text/xml; charset=UTF-8\n\n";
print "test\n";

print "res:: $http_response \n";
print "err:: $errorMessage \n";
print "------\n";
