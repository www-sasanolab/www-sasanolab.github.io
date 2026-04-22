#!/usr/bin/perl

use DBI;
use DBD::Pg;
use DBD::Pg qw(:pg_types);
use File::Slurp;
use CGI;

$CGI::POST_MAX = 1024 * 15;
$query = new CGI;

# テーブル名
$tablename = 'programs';

# URL pameter 取得
$studentID=$query->param('studentID');
$kai=$query->param('kai');
$kihon_hatten=$query->param('kihon_hatten');
$bangou=$query->param('bangou');
$status=$query->param('status');

# information for connecting database
require "/home/cs/dbinfo/dbinfo2019.txt";

# connection to database
$dbh = DBI->connect("dbi:Pg:dbname=$DB_NAME;host=$DB_HOST;port=$DB_PORT",
		    $DB_USER, $DB_PASS);
if (!(defined($dbh))) {
    print $query->header(-charset=>"utf-8");
    print $query->start_html;
    print"データベースの接続に失敗しました。</br>";
    print "<a href=\"./status.cgi\">課題提出状況ページに戻る</a>";
    print $query->end_html;
    exit;
}

# status更新
$sql = "update $tablename set status='$status'";
$sql .= " where studentID='$studentID' and kai='$kai'";
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
$sth->finish;
$dbh-> disconnect;


print $query->header(-charset=>"utf-8");
print $query->start_html;
print "statusを更新しました。</br><hr>";
print "<a href=\"./status.cgi\">課題提出状況ページに戻る</a>
（ここは戻るボタンで戻らないようにしてください。）";
print $query->end_html;
exit;
