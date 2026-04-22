#!/usr/bin/perl --

use DBI;
use DBD::Pg;
use DBD::Pg qw(:pg_types);
use File::Slurp;
use CGI;

$studentID ="$ENV{'REMOTE_USER'}";

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
my $kai = $query->param('kai');
my $kihon_hatten = $query->param('kihon-hatten');
my $bangou = $query->param('bangou');
my $file_handle = $query->upload("program");
if (!(defined($dbh))){
    print "$!\n Error: データベースの接続に失敗しました。</br>";
}
if (!(defined ($kai))) {
    print "回数を選択してください。</br>";
}
if (!(defined ($kihon_hatten))) {
    print "基本か発展を選択してください。</br>";
}
if (!($bangou =~ /[1-9]/)) {
    print "番号欄に1以上の数を入力してください。</br>";
} 
if (!(defined ($file_handle))) {
    print "ファイルを選択してください。</br>";
}
if (!(defined ($dbh)
      and defined ($kai) 
      and defined ($kihon_hatten) 
      and $bangou =~ /[1-9]/
      and defined ($file_handle))) {
    print "ブラウザの戻るボタンでファイル提出ページに戻ってやり直してください。</br>";
    print $query->end_html;
    exit;
}

my $tablename = 'programs';

# teishutuok確認
my $sql = "select * from teishutsuok ";
$sql .= "where kai='$kai' and kihon_hatten='$kihon_hatten'";
$sql .= " and bangou='$bangou';";
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
    print "この課題は提出できません。</br>";
    print $query->end_html;
    exit;
}

# status取得
my $sql = "select status from $tablename ";
$sql .= "where kai='$kai' and kihon_hatten='$kihon_hatten'";
$sql .= " and bangou='$bangou' and studentID='$studentID';";
my $sth = $dbh->prepare($sql);
$sth->execute();
$error_message = $sth->errstr;
if ($error_message) {
    print "error message(1): " . $error_message . "</br>";
    print $query->end_html;
    $sth->finish;
    $dbh-> disconnect;
    exit;
}
my $ary_ref = $sth->fetchrow_arrayref;
my $status;
$sth->finish;
if ($ary_ref) {
    ($status) = @$ary_ref;
    if ($status eq 1 or $status eq 3) {
	if ($status eq 1) {
	    print "この課題のファイルは提出済み（TA確認待ち）です。</br>";
	}
	if ($status eq 3) {
	    print "この課題はTA確認済です。</br>";
	}
	print "ブラウザの戻るボタンで課題提出ページに戻ってやり直してください。</br>";
	print $query->end_html;
	exit;
    }
}

# ファイルをtableに書き込み
my $sql;
if (!(defined ($status))) {
    $sql = "insert into $tablename (studentID, kai, kihon_hatten, bangou, status, program) ";
    $sql .= "values ('$studentID', '$kai', '$kihon_hatten', '$bangou', 1, ?);";
} elsif ($status eq 2) {
    $sql = "update $tablename set status = 1, program = ? ";
    $sql .= "where studentID='$studentID' and kai='$kai'";
    $sql .= " and kihon_hatten='$kihon_hatten' and bangou='$bangou';";
} else {
    print "エラー</br>";
    print $query->end_html;
    exit;
}
my $sth = $dbh->prepare($sql);
my $filedata = read_file($file_handle);
$sth->bind_param(1, $filedata, {pg_type => DBD::Pg::PG_BYTEA});
$sth->execute();
$error_message = $sth->errstr;
if ($error_message) {
    print "error message(2): " . $error_message . "</br>";
    print $query->end_html;
    $sth->finish;
    $dbh-> disconnect;
    exit;
}
$sth->finish;

print "課題が提出されました。</br>";
print "<hr>";
print "<a href=\"./status.cgi\">課題提出状況ページ</a>";
print $query->end_html;
exit;
