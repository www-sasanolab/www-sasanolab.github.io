#!/usr/bin/perl

# 学生用課題提出状況ページ

use CGI;
use DBI;
$CGI::POST_MAX = 1024 * 15;
$query = new CGI;

print $query->header(-charset=>"utf-8");
print $query->start_html(-title=>"課題提出状況");

$studentID ="$ENV{'REMOTE_USER'}";

# information for connecting database
require "/home/cs/dbinfo/dbinfo2019.txt";

# connection to database
$dbh = DBI->connect("dbi:Pg:dbname=$DB_NAME;host=$DB_HOST;port=$DB_PORT",$DB_USER,$DB_PASS) or die "$!\n Error: failed to connect to DB.\n";

$sql = "SELECT name,hurigana,han,kyoryoku from rishusha";
$sql .= " where studentID = '$studentID';";
$sth = $dbh->prepare($sql);
$sth->execute();
$error_message = $sth->errstr;
if ($error_message) {
    print "error message(1): " . $error_message . "</br>";
    $sth->finish;
    $dbh-> disconnect;
    print $query->end_html;
    exit;
}

$ary_ref = $sth->fetchrow_arrayref;
$sth->finish;
if ($ary_ref) {
    ($name,$hurigana,$han,$kyoryoku) = @$ary_ref;
} else {
    print "学籍番号がデータベースにありません。</br>";
    print $query->end_html;
    exit;
}

my $sql = "SELECT kai,kihon_hatten,bangou,status,comment,jikoku from programs";
$sql .= " where studentID = '$studentID'";
$sql .= " order by status, kihon_hatten, kai, bangou;";
my $sth = $dbh->prepare($sql);
$sth->execute();
$error_message = $sth->errstr;
if ($error_message) {
    print "error message(2): " . $error_message . "</br>";
    $sth->finish;
    $dbh-> disconnect;
    print $query->end_html;
    exit;
}

print "課題提出状況" . "</br>";
print "$han" . "班" . "&nbsp;&nbsp;&nbsp;";
print $studentID . "&nbsp;&nbsp;&nbsp;";
print $name . "&nbsp;&nbsp;&nbsp;";
#print $hurigana;
# print "（実験に協力";
# if ($kyoryoku eq 1) {
#     print "する";
# } else {
#     print "しない";
# }
# print "）";


print "<table border=1 cellpadding=3 cellspacing=0>";
print "<tr>";
print "<td>";print "課題番号";print "</td>";
print "<td>";print "status";print "</td>";
print "<td>";print "提出ファイル";print "</td>";
print "<td>";print "コメント";print "</td>";
print "<td>";print "更新時刻";print "</td>";
print "</tr>";

while (my $ary_ref = $sth->fetchrow_arrayref) {
    my ($kai, $kihon_hatten, $bangou, $status, $comment, $jikoku) = @$ary_ref; # @をつけて配列にする
    # $ary_refは配列へのレファレンス
    print "<tr>";
    print "<td>";
    print "第" . $kai . "回";
    if ($kihon_hatten eq "1") {
	print "基本";
    } elsif ($kihon_hatten eq "2") {
	print "発展";
    } else {
	print "エラー";
    }
    print $bangou;
    print "</td>";
    print "<td>";
    if ($status eq "1") {
	print "TA確認待ち";
    } elsif ($status eq "2") {
	print "再提出要";
    } elsif ($status eq "3") {
	print "OK";
    } else {
	print "エラー";
    }
    print "</td>";
    print "<td>";
    print "<a href=\"./download.cgi?kai=$kai&kihon_hatten=$kihon_hatten&bangou=$bangou\">download</a>";
    print "</td>";
    print "<td>";
    print $comment;
    print "</td>";
    print "<td>";
    print $jikoku;
    print "</td>";
}
print "</table>";

$sth->finish;
$dbh-> disconnect;

print "<hr>";
print "<a href=\"./submit.html\">課題提出ページ</a>（再提出も含む）";
print $query->end_html;
exit;
