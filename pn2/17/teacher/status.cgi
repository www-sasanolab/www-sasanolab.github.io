#!/usr/bin/perl

# TA用課題提出状況ページ

use CGI;
use DBI;
$CGI::POST_MAX = 1024 * 15;
$query = new CGI;

print $query->header(-charset=>"utf-8");
print $query->start_html(-title=>"課題提出状況");

$TAID ="$ENV{'REMOTE_USER'}";

# information for connecting database
require "/home/cs/dbinfo/dbinfo2017.txt";

# connection to database
$dbh = DBI->connect("dbi:Pg:dbname=$DB_NAME;host=$DB_HOST;port=$DB_PORT",$DB_USER,$DB_PASS) or die "$!\n Error: failed to connect to DB.\n";

$han = 10; #班を指定するとその班のTAと同等のことができるようになっている。
print $han . '班';
print "課題提出状況" . "</br>";

$sql = "SELECT programs.studentID,rishusha.name,kai,kihon_hatten,bangou,status,jikoku";
$sql .= " from programs,rishusha";
$sql .= " where han=$han and programs.studentID=rishusha.studentID;";
$sth = $dbh->prepare($sql);
$sth->execute();
$error_message = $sth->errstr;
if ($error_message) {
    print "error message(2): " . $error_message . "</br>";
    $sth->finish;
    $dbh-> disconnect;
    print $query->end_html;
    exit;
}

print "<table border=1 cellpadding=3 cellspacing=0>";
print "<tr>";
print "<td>";print "班";print "</td>";
print "<td>";print "学籍番号";print "</td>";
print "<td>";print "氏名";print "</td>";
print "<td>";print "課題番号";print "</td>";
print "<td>";print "status";print "</td>";
print "<td>";print "提出ファイル";print "</td>";
print "<td>";print "TA確認";print "</td>";
print "<td>";print "status更新時刻";print "</td>";
print "</tr>";

while (my $ary_ref = $sth->fetchrow_arrayref) {
    my ($studentID, $name, $kai, $kihon_hatten, $bangou, $status, $jikoku) = @$ary_ref; # @をつけて配列にする
    # $ary_refは配列へのレファレンス
    print "<tr>";
    print "<td>" . $han . "</td>";
    print "<td>" . $studentID . "</td>";
    print "<td>" . $name . "</td>";
    print "<td>";
    print "第" . $kai . "回";
    if ($kihon_hatten eq "1") {
	print "基本";
    } elsif ($kihon_hatten eq "2") {
	print "発展";
    } else {
	print "エラー2";
    }
    print $bangou;
    print "</td>";
    print "<td>";
    if ($status eq "1") {
	print "TA確認待ち";
    } elsif ($status eq "2") {
	print "再提出待ち";
    } elsif ($status eq "3") {
	print "OK";
    } else {
	print "エラー3";
    }
    print "</td>";
    print "<td>";
    print "<a href=\"./download.cgi?studentID=$studentID&kai=$kai&kihon_hatten=$kihon_hatten&bangou=$bangou\">download</a>";
    print "</td>";
    print "<td>";
    if ($status eq "1") {
	print "<button onclick=\"location.href='./update.cgi?studentID=$studentID&kai=$kai&kihon_hatten=$kihon_hatten&bangou=$bangou&status=3'\">正解</a>";
	print "<button onclick=\"location.href='./update.cgi?studentID=$studentID&kai=$kai&kihon_hatten=$kihon_hatten&bangou=$bangou&status=2'\">不正解</a>";
    }
    print "</td>";
    print "<td>";
    print $jikoku;
    print "</td>";
}
print "</table>";

$sth->finish;
$dbh-> disconnect;

print "<hr>";
print $query->end_html;
exit;
