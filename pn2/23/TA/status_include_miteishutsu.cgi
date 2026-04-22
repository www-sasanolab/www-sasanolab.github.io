#!/usr/bin/perl --

use DBI;
use DBD::Pg;
use DBD::Pg qw(:pg_types);
use File::Slurp;
use CGI;

$TAID ="$ENV{'REMOTE_USER'}";

$CGI::POST_MAX = 1024 * 15;
$query = new CGI;

# information for connecting database
require "/home/cs/dbinfo/dbinfo2023.txt";

print $query->header(-charset=>"utf-8");
print $query->start_html;

my $cgi_error = $query->cgi_error();
if ($cgi_error) {
    print $cgi_error . "</br>";
    print "ブラウザの戻るボタンでファイル提出ページに戻ってやり直してください。</br>";
    print $query->end_html;
    exit;
}

# connection to database
my $dbh = DBI->connect("dbi:Pg:dbname=$DB_NAME;host=$DB_HOST;port=$DB_PORT",
		       $DB_USER, $DB_PASS);
my $num = $query->param('num');
if (!(defined($dbh))){
    print "$!\n Error: データベースの接続に失敗しました。</br>";
}
if (!(defined ($num))) {
    print "学籍番号が入力されていません。ブラウザの戻るボタンで戻ってやり直してください。</br>";
    print $query->end_html;
    exit;
}

$studentID = 'AL' . $num;

#学生が担当班学生かどうか確認
my $sql = "select * from TA,rishusha where TAID='$TAID' and studentID='$studentID' and TA.han=rishusha.han;";
$sth = $dbh->prepare($sql);
$sth->execute();
$error_message = $sth->errstr;
if ($error_message) {
    print "error message(1): " . $error_message . "</br>";
    print $query->end_html;
    $sth->finish;
    $dbh-> disconnect;
    exit;
}
$ary_ref = $sth->fetchrow_arrayref;
$sth->finish;

if ($ary_ref) {
} else {
    print "この学生はあなたの班の学生ではありません。</br>";
    print $query->end_html;
    exit;
}

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

my $sql = "with p as (SELECT kai,kihon_hatten,bangou,status,comment,jikoku from programs";
$sql .= " where studentID = '$studentID')";
$sql .= " select t.kai, t.kihon_hatten, t.bangou, p.status, p.comment, p.jikoku from";
$sql .= " p right join teishutsuok t";
$sql .= " on p.kai=t.kai and p.kihon_hatten=t.kihon_hatten and p.bangou=t.bangou";
$sql .= " order by p.status, t.kihon_hatten, t.kai, t.bangou;";
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
print "$studentID" . "&nbsp;&nbsp;&nbsp;";
print "$name" . "&nbsp;&nbsp;&nbsp;";
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
	print "未提出";
    }
    print "</td>";
    print "<td>";
    if ($status) {
	print "<a href=\"./download.cgi?kai=$kai&kihon_hatten=$kihon_hatten&bangou=$bangou\">download</a>";
    }
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
print "<a href=\"https://www.cs.ise.shibaura-it.ac.jp/pn2/23/kadai.html\">課題提出について</a>";

print $query->end_html;
exit;
