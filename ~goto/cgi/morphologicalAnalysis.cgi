#!/usr/bin/ruby
require 'net/http'
require "cgi-lib"
require "cgi"
cgi = CGI.new
inputText = cgi['text']
inputText = CGI.escape(inputText)

print "Content-type: text/xml\n\n"

$proxy_addr = 'proxy.ise.shibaura-it.ac.jp'
$proxy_port = 10080


Net::HTTP.version_1_2   # おまじない

Net::HTTP::Proxy($proxy_addr, $proxy_port).start( 'jlp.yahooapis.jp' ) {|http|
  response = http.post('/MAService/V1/parse',
			"appid=HAT0Veexg643G0kKK7KQWZRrHEsp.WiP_adgFJI1nbnUz0pAl1gwSRqqr4ipPPU-&results=ma,uniq&uniq_filter=9|10&sentence="+inputText)
  puts response.body
}

