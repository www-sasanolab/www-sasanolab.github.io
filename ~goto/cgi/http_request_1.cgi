#!/usr/bin/ruby
require 'net/http'
require "cgi-lib"

print "Content-type: text/html\n\n"

$proxy_addr = 'proxy.ise.shibaura-it.ac.jp'
$proxy_port = 10080


Net::HTTP.version_1_2   # おまじない

Net::HTTP::Proxy($proxy_addr, $proxy_port).start( 'www.google.co.jp' ) {|http|
  response = http.get('/index.html')
  puts response.body
}

