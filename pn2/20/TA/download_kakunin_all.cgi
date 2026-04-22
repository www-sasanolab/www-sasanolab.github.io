#!/usr/bin/perl

use DBI;
use DBD::Pg;
use DBD::Pg qw(:pg_types);
use File::Slurp;
use CGI;
use IO::Compress::Zip qw(:all);

$CGI::POST_MAX = 1024 * 15;
$query = new CGI;

$TAID ="$ENV{'REMOTE_USER'}";

# テーブル名
$tablename = 'programs';

# URL pameter 取得
$han=$query->param('han');

# information for connecting database
require "/home/cs/dbinfo/dbinfo2020.txt";

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
$sql = "SELECT program,programs.studentID,kai,kihon_hatten,bangou";
$sql .= " from programs,TA,rishusha";
$sql .= " where TA.han=rishusha.han";
$sql .= " and programs.studentID=rishusha.studentID";
$sql .= " and status='1'";
$sql .= " and TA.TAID='$TAID'";
$sql .= " order by kihon_hatten, kai, bangou, programs.studentID;";
$sth = $dbh->prepare($sql);
$sth->execute();
$error_message = $sth->errstr;
if ($error_message) {
    print $query->header(-charset=>"utf-8");
    print $query->start_html;
    print "error message(2): " . $error_message . "</br>";
    $sth->finish;
    $dbh-> disconnect;
    print $query->end_html;
    exit;
}

$zipfileName = $han . "han.zip";

print "Content-Type:application/zip\n";
print "Content-Disposition: attachment; filename=\"$zipfileName\"\n\n";

my $z;

while (my $ary_ref=$sth->fetchrow_arrayref) {
    my ($program, $studentID, $kai, $kihon_hatten, $bangou) = @$ary_ref; # @をつけて配列にする
    my $kh;
    if ($kihon_hatten eq 1) {
	$kh='kihon';
    } elsif ($kihon_hatten eq 2) {
	$kh='hatten';
    } else {
	$kh='error';
    }
    # 各ァイル名
    my $fileName = $kh . $kai . '-' . $bangou . '-' . $studentID . '.c';

    if ($z) {
	$z->newStream(Name => $fileName, Method => ZIP_CM_STORE);
    } else {
	$z = new IO::Compress::Zip "-", Name => $fileName, Method => ZIP_CM_STORE;
    }
    $z->print($program);
}
$z->close;
$sth->finish;
$dbh-> disconnect;

exit;
