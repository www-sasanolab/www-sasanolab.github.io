#!/usr/bin/perl

use DBI;
use DBD::Pg;
use DBD::Pg qw(:pg_types);
use File::Slurp;
use CGI;

$studentID ="$ENV{'REMOTE_USER'}";

$CGI::POST_MAX = 1024 * 15;
$query = new CGI;

# テーブル名
$tablename = 'programs';

# URL pameter 取得
$kai=$query->param('kai');
$kihon_hatten=$query->param('kihon_hatten');
$bangou=$query->param('bangou');

# information for connecting database
require "/home/cs/dbinfo/dbinfo2019.txt";

# connection to database
$dbh = DBI->connect("dbi:Pg:dbname=$DB_NAME;host=$DB_HOST;port=$DB_PORT",
		       $DB_USER, $DB_PASS);
if (!(defined($dbh))) {
    print $query->header(-charset=>"utf-8");
    print $query->start_html;
    print"データベースの接続に失敗しました。</br>";
    print "<a href=\"./submit.html\">ファイル提出画面に戻る</a>";
    print $query->end_html;
    exit;
}

# ファイル取得
$sql = "select program from $tablename ";
$sql .= "where studentID='$studentID' and kai='$kai'";
$sql .= " and kihon_hatten='$kihon_hatten' and bangou='$bangou';";
$sth = $dbh->prepare($sql);
$sth->execute();
$error_message = $sth->errstr;
if ($error_message) {
    print $query->header(-charset=>"utf-8");
    print $query->start_html;
    print "error message: ";
    print $error_message;
    print "</br>";
}
$ary_ref = $sth->fetchrow_arrayref; # 結果は1つなので1回呼ぶだけでOK。
($program) = @$ary_ref; # 括弧を外すとエラーになる。要素1つからなる配列なので。
$sth->finish;
$dbh-> disconnect;

# download時のファイル名
my $kh;
if ($kihon_hatten eq 1) {
    $kh='kihon';
} elsif ($kihon_hatten eq 2) {
    $kh='hatten';
} else {
    $kh='error';
}
my $file_name = $kh . $kai . '-' . $bangou . '-' . $studentID . '.c';

# ファイル送信
print "Content-Type: application/download\n";
print "Content-Disposition: attachment; filename=\"$file_name\"\n\n";
binmode STDOUT;
print $program;
exit;
