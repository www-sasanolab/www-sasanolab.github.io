#!/usr/bin/perl

# TA用評価確認ページ

use CGI;
use DBI;
$CGI::POST_MAX = 1024 * 15;
$query = new CGI;

$TAID ="$ENV{'REMOTE_USER'}";

# information for connecting database
require "/home/cs/dbinfo/dbinfo.txt";

# connection to database
$dbh = DBI->connect("dbi:Pg:dbname=$DB_NAME;host=$DB_HOST;port=$DB_PORT",$DB_USER,$DB_PASS) or die "$!\n Error: failed to connect to DB.\n";

$sql = "SELECT han,name from TA where TAID='$TAID';";
$sth = $dbh->prepare($sql);
$sth->execute();
$error_message = $sth->errstr;
if ($error_message) {
    print $query->header(-charset=>"utf-8");
    print $query->start_html(-title=>"成績");
    print "error message(1): " . $error_message . "</br>";
    $sth->finish;
    $dbh-> disconnect;
    print $query->end_html;
    exit;
}

my $han;
$ary_ref = $sth->fetchrow_arrayref;
$sth->finish;
if ($ary_ref) {
    ($han,$TA_name) = @$ary_ref;
} else {
    print $query->header(-charset=>"utf-8");
    print $query->start_html(-title=>"成績");
    print "このTAはデータベースにありません。</br>";
    print $query->end_html;
    exit;
}

$sql = "SELECT studentID from rishusha,TA";
$sql .= " where TA.han=rishusha.han";
$sql .= " and TA.TAID='$TAID';";
$sth = $dbh->prepare($sql);
$sth->execute();
$error_message = $sth->errstr;
if ($error_message) {
    print $query->header(-charset=>"utf-8");
    print $query->start_html(-title=>"成績");
    print "error message(2): " . $error_message . "</br>";
    $sth->finish;
    $dbh-> disconnect;
    print $query->end_html;
    exit;
}

my $file_name = $han . '.csv';

# ファイル送信
print "Content-Type: application/download\n";
print "Content-Disposition: attachment; filename=\"$file_name\"\n\n";
binmode STDOUT;

while (my $ary_ref = $sth->fetchrow_arrayref) {
    my ($studentID) = @$ary_ref; # @をつけて配列にする
    # $ary_refは配列へのレファレンス
    print $studentID;
    print "\n";
}

$sth->finish;
$dbh-> disconnect;

exit;
