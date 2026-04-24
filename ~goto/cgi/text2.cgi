#!/usr/bin/perl 

use strict;
use warnings;
use CGI;

my $cgi = CGI->new();
print $cgi->header( -charset => 'euc' );
if ( $cgi->param('name') ) {
    my $name = $cgi->param('name');
    $name = $cgi->escapeHTML($name);
    printf( 'あなたのナマエは<b>%s</b>ですね', $name );
}
else { 
    print <DATA>;
}

__END__
<html>
<head>
<title>POST Sample</title>
</head>
<body>
    <h1>ポストしようぜ！</h1>
    <form method="post">
        ナマエ : <input type="text" name ="name"><br>
        <input type="submit" value="ポストするぜ">
    </form>
</body>
</html>
