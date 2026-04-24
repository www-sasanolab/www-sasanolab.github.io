#!/usr/bin/perl

use CGI;
use DBI;
use Encode;
use utf8;
use HTML::Template;

my $template = HTML::Template->new(filename=>'index.tmpl');

my $q = CGI->new;
$q->charset('utf-8');

#database
my $dbh = DBI->connect('DBI:mysql:tehepero','tehepero','inm7tehepero');
$dbh->do("set names utf8");

$template->param(title=>'てへぺろ（・ω＜）');

$dbq = $dbh->prepare("select * from user");
$dbq->execute;


my @loop_data = ();

while(@row = $dbq->fetchrow_array){
    my %row_data;

    $row_data{name} = Encode::decode('utf8',$row[2]);
    $row_data{id} = Encode::decode('utf8',$row[1]);
						    
    #print "-> ". $row[2] . "<br>\n";
    push(@loop_data,\%row_data);
}

#HTML

$template->param(loop_user=>\@loop_data);

print $q->header(-charset=>'utf-8');
print $template->output;


$dbq->finish;
$dbh->disconnect;

exit(0);






