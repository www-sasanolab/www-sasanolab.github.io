#! /usr/bin/perl
#
# updown.cgi
#
# 2.075 : 12/20/07 : エラーメッセージを修正
# 2.074 : 1/3/07 : body内挿入分の「タイトルの下」を修正
# 2.073 : 8/9/06 : ページ内挿入分設定を追加
# 2.072 : 5/9/06 : テンポラリファイルが残るバグを修正
# 2.071 : 1/25/06 : ローカルタイムモードを追加
# 2.070 : 11/14/05 : アップファイル名の処理を修正
# 2.069 : 10/6/05 : メンバー専用パスワードを追加
# 2.068 : 10/1/05 : Copyrightにリンクを追加
# 2.067 : 9/24/05 : 拡張子を省略した場合元の拡張子を使うように修正
# 2.066 : 9/22/05 : Headerにcharsetを追加
# 2.065 : 9/10/05 : アップロード禁止モードを追加
# 2.064 : 8/28/05 : アップロード方法を変更
# 2.063 : 8/25/05 : アップ後のファイル名にハイフンを許可するように変更
#                   jcode.pl, cgi-lib.plを削除。cryptを変更。
# 2.062 : 2/19/05 : リンククリック時のオプションを追加
# 2.061 : 2/6/05 : Locationを修正
# 2.06 : 1/14/05 : リストファイルにホスト名を記録するように修正
# 2.05 : 4/14/03 : セットアップ画面追加
#                  ソースの構造を変更
#                  コピーライトの年数表示を修正
# 2.04 : 3/31/03 : アップファイル最大サイズ設定追加
#                  削除したときリストファイルから改行が抜けるバグを修正
#                  トップへのリンクを追加
# 2.03 : 3/25/03 : 著作権表記を追加
#                  セットアップファイルを使えるように変更
# 2.02 : 3/24/03 : パスワード作成失敗エラー処理を追加
# 2.01 : 1/28/03 : ＩＥで正しくアップロードできなかったのを修正
# 2.0  : 11/24/02 : パスワード機能を追加
#       showdllst.plとwrdllst.plをupdown.cgiの一つに統合
#
# $Id: updown.cgi,v 1.34 2007/12/20 06:00:21 Hideki Kanayama Exp $
# Copyright(c) 2002-2007 Hideki Kanayama All rights reserved

use strict;
use CGI qw(:cgi-lib);
use CGI::Carp qw(fatalsToBrowser);
use File::Copy;
use File::Basename;

my $version = "2.075";
my $lastmodifiedyear = "2007";

my $admindat = "adminpwd.dat";
my $setupfile = "updown_setup.pl";

my $script = basename($0);

my $charset = "Shift_JIS";

my $lang = 0;

############# 環境設定ここから ########################

our $dldir = "./updown";
our $dllistfile = "$dldir/updown.lst";

# バックグラウンド設定
our $bgimage_en = 1;
our $bgimagefile="$dldir/sample.jpg";
our $bgcolor="ffffff";

#タイトル
our $title = '篠埜研ファイルアップローダ';

#トップへのリンク
our $toplink_en = 1;
our $toplink_link = "/";
our $toplink_title = 'トップへ';

# リンククリック時 0:同じウィンドウ、1:別ウィンドウ、2:指定拡張子のみ別ウィンドウ
our $link_target = 0;
our $link_extention = "jpg gif png";  # 半角スペースで区切る

# アップロード禁止な拡張子
our $prohibit_en = 1;
our $prohibit_extention = "cgi pl csh sh";  # 半角スペースで区切る

#アップファイル最大サイズ(ＭＢ)
our $maxsize2 = 1024;

#メンバー専用パスワード 1:on 0:off
our $member_only = 0;
our $member_pwd = '12345';

#スタイルシート
our $style_sheet_en = 1;
our $style_sheet = '
<!--
A:link {text-decoration: none}
A:visited {text-decoration: none}
A:acteve {text-decoration: none}
//-->
';

#<head>挿入文
our $head_insert_en = 0;
our $head_insert = '<META NAME="description" CONTENT="profile">';

# 時間設定
our $localtime_en = 1;
our $offset_from_gmt = 9;

#ページ上部に表示させる文 1:on, 0:off
our $body_insert1_en = 0;
our $body_insert2_en = 0;
our $body_insert3_en = 0;
our $body_insert1 = '';
our $body_insert2 = '';
our $body_insert3 = '';

############# 環境設定ここまで ########################

if (-e "$setupfile"){
	require "$setupfile";
}

my $bgset;
if ($bgimage_en == 1){
    $bgset = "background=\"$bgimagefile\"";
} else {
    $bgset = "bgcolor=\"$bgcolor\"";
}

$CGI::POST_MAX = $maxsize2 * 1048576;
my $maxsize = $CGI::POST_MAX;

if ($maxsize > 1048576){
    $maxsize = sprintf("%.1fMB",$maxsize/1048576);
} elsif ($maxsize > 1024){
    $maxsize = sprintf("%.1fkB",$maxsize/1024);
} else {
    $maxsize = sprintf("%dB",$maxsize);
}

my $q = new CGI;
my $cgierror = $q->cgi_error;
&error($cgierror) if ($cgierror);
my %in = $q->Vars;

while (my ($key,$value)=each %in){
    if ($key ne 'upfile'){
	
	$value =~ s/</&lt;/g; $value =~ s/>/&gt;/g;
	
	my $br;
	if ($key eq 'style_sheet' ||
	    $key eq 'head_insert' ||
	    $key eq 'body_insert1' ||
	    $key eq 'body_insert2' ||
	    $key eq 'body_insert3'
	    ){
	    $br = "<br>";
	} else {
	    $br = "";
	}
	if ($value =~ /\r\n/) { $value =~ s/\r\n/$br/g; }
	if ($value =~ /\n/) { $value =~ s/\n/$br/g; }
	if ($value =~ /\r/) { $value =~ s/\r/$br/g; }
	if ($value =~ /,/) { $value =~ s/,/&\#44;/g; }
			     
	$in{"$key"}=$value;
    }
}

if (! -e "$admindat"){
    if ($in{mode} ne 'adminpwd'){
	&setadminpwd;
    } else {
	&wradminpwd;
    }
}

if ($in{mode} eq 'register'){
    &register;
} elsif ($in{mode} eq 'delete'){
    &delete;
} elsif ($in{mode} eq 'setup'){
    &setup;
} elsif ($in{mode} eq 'wrsetup'){
    &wrsetup;
} else {
    &display;
}

################## 登録 ###########################
sub register {

    if ($in{'sub'} eq "" || $in{'upfile'} eq "") {
	&error("$in{sub}:$in{upfile}:タイトル、またはファイル名を正しく入れてください。");
    }
    
    if ($in{'pwd'} eq "") {
	&error("削除用パスワードを正しく入れてください。");
    }

    &error("メンバー用パスワードが違います。") if ($in{member_pwd} ne $member_pwd and $member_only == 1);

    my $fname;
    my $upfile = $q->param('upfile');
    my ($tmp1, $tmp2, $orgext) = fileparse($upfile,'\.[^\.]*?$');
    if ($in{'fname'} eq ""){
	$fname = basename($upfile);
    } else {
	$fname=$in{'fname'};
    }
    $fname =~ s/^.+[\/\\]([^\/\\]+)$/$1/; #just in case
    $fname .= "$orgext" if ($fname !~ /\.[^\.]*?$/);

    if ($fname !~ /^[\w\.\-]+$/) {
	&error("$fname:アップ後のファイル名は半角英数、ドット、ハイフン、アンダースコアで。");
    }
    
    my @suffix_list = split /\s+/, $prohibit_extention;
    my ($body_name, $path_name, $suf_name) = fileparse($fname,@suffix_list);
    if ($suf_name and $prohibit_en){
	&error("$suf_nameの拡張子ではアップロードが禁止されています。");
    }
    
    my $outfile = "$dldir/$fname";
    
    if (-e "$outfile") {
	&error("同じファイル名がサーバー上に存在します。<br>アップ後のファイル名を変更してやり直してください。");
    }
    
    my $fh = $q->upload('upfile');
    my $cgierror = $q->cgi_error;
    &error($cgierror) if (!$fh && $cgierror);
    copy ($fh, $outfile) or &error("アップロードに失敗しました:$!");
    close($fh);
    chmod (0666,$outfile);
    
    
    my ($d_dev,$d_ino,$d_mode,$d_nlink,$d_uid,$d_gid,$d_rdev,$d_size,$d_atime,$d_mtime,$d_ctime,$d_blksize,$d_blocks)=stat("$outfile");
    
    my $size;
    if ($d_size > 1048576){
	$size = sprintf("%.1fMB",$d_size/1048576);
    } elsif ($d_size > 1024){
	$size = sprintf("%.1fkB",$d_size/1024);
    } else {
	$size = sprintf("%dB",$d_size);
    }
    
    open(DLFILE,"< $dllistfile");
    my $count;
    my @dummy;
    while(<DLFILE>){
	($count,@dummy)=split(/,/);
    }
    close(DLFILE);
    
    $count++;
    
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)= $localtime_en ? localtime($d_mtime) : gmtime($d_mtime+$offset_from_gmt*3600);
    my $update = sprintf("%s年%s月%s日%02s時%02s分",$year+1900,$mon+1,$mday,$hour,$min);
    
    my $remote_host=$ENV{'REMOTE_HOST'};
    my $remote_addr=$ENV{'REMOTE_ADDR'};
    
    my $encpwd = &makecrypt($in{pwd});
    
    open(DAT,">> $dllistfile");
    print DAT "$count,$fname,$in{sub},$size,$update,$encpwd,$remote_host,$remote_addr\n";
    close(DAT);
    
    chmod(0666,"$dllistfile");
    
    print "Location: $script\n\n";
    
}

######################　削除　#########################
sub delete {
    
    if ($in{'deletefile'} == 0) {
	&error("削除するタイトルを選んでください。");
    }
    
    my $delnumber = $in{deletefile};
    
    if ($in{'pwd'} eq "") {
	&error("削除用パスワードを正しく入れてください。");
    }
    
    my @newlist=();
    open(DLFILE,"< $dllistfile");
    while(<DLFILE>){
	chomp;
	my ($count,$file,$title,$size,$update,$pwd,$host,$addr)=split(/,/);
	if ($count == $delnumber){
	    if ((&checkcrypt($in{pwd},"$pwd") && ($pwd ne ''))
		|| &checkcrypt($in{pwd},&adminpwd)){
		unlink("$dldir/$file");
	    } else {
		&error("パスワードが違います。");
	    }
	} else {
	    push(@newlist,"$_\n");
	}
    }
    close(DLFILE);
    
    open(DAT,"> $dllistfile");
    print DAT @newlist;
    close(DAT);
    
    print "Location: $script\n\n";
}

##############################　セットアップ　################################
sub setup {
    
    if ($in{'pwd'} eq "") {
	&error("管理用パスワードを正しく入れてください。");
    }
    
    if (!&checkcrypt($in{pwd},&adminpwd)){
	&error("パスワードが違います。");
    }
    
    &beginning;
    
    my @bgimage_check;
    my @toplink_check;
    my @head_insert_check;
    my @style_sheet_check;
    my @link_target_check;
    my @prohibit_check;
    my @member_only_check;
    my @localtime_check;
    my @body_insert1_check;
    my @body_insert2_check;
    my @body_insert3_check;
    $bgimage_check[$bgimage_en] = "checked";
    $toplink_check[$toplink_en] = "checked";
    $head_insert_check[$head_insert_en] = "checked";
    $style_sheet_check[$style_sheet_en] = "checked";
    $link_target_check[$link_target] = "checked";
    $prohibit_check[$prohibit_en] = "checked";
    $member_only_check[$member_only] = "checked";
    $localtime_check[$localtime_en] = "checked";
    $body_insert1_check[$body_insert1_en] = "checked";
    $body_insert2_check[$body_insert2_en] = "checked";
    $body_insert3_check[$body_insert3_en] = "checked";
    
    print <<SETUPWIN;
<form action="$script" method=post>
<input type=hidden name=mode value=wrsetup>
<input type=hidden name=pwd value=$in{pwd}>
<table cols=2 border=1 width="100%">
<tr>
<td colspan=2>
<ul>
<li>ディレクトリ、ファイルの設定は、$scriptから見た相対パス、又は絶対パスで指定してください。ＣＧＩと同じディレクトリの場合、.（半角ドット）でＯＫです。バックグランドファイルやロゴファイルはhttp://からのリンクの指定も可能\です。</li>
	<li>管理人パスワードを変更するには、$admindatを削除して、$scriptを実行しなおしてパスワードを再入力してください。</li>
<li>これらの設定は$setupfileに保存されます。また、$setupfileをエディタ等で変更してもこの設定ページに反映されます。</li>
<li>$scriptがバージョンアップされた場合、単純に$scriptだけを置き換えるだけで設定はそのまま使えます。</li>
<li>$admindatと$setupfileのファイル名はこの設定ページでは変更できません。変更したい場合は$scriptの中で変更してください。</li>
<li>管理人パスワードで他人の登録ファイルを削除することができます。</li>
<li><font color=red>数字やカラー指定は必ず半角で指定してください。全角やブランクだとＣＧＩが起動しなくなります。</font>万一間違って全角で書いてしまった場合は、$setupfileをエディタで開きその場所を半角に正しく修正してください。それで直ります。</li>
</ul>
</td>
</tr>

<tr>
<td width="20%">
データディレクトリ
</td>
<td width="80%">
<input type=text name=dldir value=$dldir size=30>
</td>
</tr>

<tr>
<td>
データファイル
</td>
<td>
<input type=text name=dllistfile value=$dllistfile size=30>
</td>
</tr>

<tr>
<td>バックグランド</td>
<td>
<input type=radio name=bgimage_en value=1 $bgimage_check[1]>画像を使う
<input type=radio name=bgimage_en value=0 $bgimage_check[0]>カラー設定にする<br>
<input type=text name="bgimagefile" value="$bgimagefile" size=30>画像を使う場合の画像ファイル<br>
<input type=text name="bgcolor" value="$bgcolor" size=30>カラー設定の場合のカラー番号（白：\#ffffff 又は white）
</td>
</tr>

<tr>
<td>
タイトル
</td>
<td>
<input type=text name=title value=$title size=30>
</td>
</tr>

<tr>
<td>トップへのリンク表\示</td>
<td>
<input type=radio name=toplink_en value=1 $toplink_check[1]>有り
<input type=radio name=toplink_en value=0 $toplink_check[0]>無し<br>
<input type=text name="toplink_link" value="$toplink_link" size=30>トップのリンク先<br>
<input type=text name="toplink_title" value="$toplink_title" size=30>リンク名
</td>
</tr>

<tr>
<td>アップファイルのリンククリック時</td>
<td>
<input type=radio name=link_target value=0 $link_target_check[0]>同じウィンドウ
<input type=radio name=link_target value=1 $link_target_check[1]>別ウィンドウ
<input type=radio name=link_target value=2 $link_target_check[2]>指定の拡張子のみ別ウィンドウ<br>
拡張子<input type=text name="link_extention" value="$link_extention" size=30>半角スペースで区切ってください<br>
</td>
</tr>

<tr>
<td>アップロード禁止</td>
<td>
<input type=radio name=prohibit_en value=0 $prohibit_check[0]>無効
<input type=radio name=prohibit_en value=1 $prohibit_check[1]>有効<br>
拡張子<input type=text name="prohibit_extention" value="$prohibit_extention" size=30>半角スペースで区切ってください<br>
</td>
</tr>

<tr>
<td>
アップファイル最大サイズ
</td>
<td>
<input type=text name=maxsize2 value=$maxsize2 size=10>ＭＢ
</td>
</tr>

<tr>
<td>メンバー用パスワード</td>
<td>
<input type=radio name=member_only value=1 $member_only_check[1]>有効
<input type=radio name=member_only value=0 $member_only_check[0]>無効<br>
<input type=password name="member_pwd" value="$member_pwd" size=10>メンバー用パスワード（半角英数で）<br>
</td>
</tr>

<tr>
<td>&lt;head&gt;内挿入文</td>
<td>
<input type=radio name=head_insert_en value=1 $head_insert_check[1]>有効
<input type=radio name=head_insert_en value=0 $head_insert_check[0]>無効<br>
ＨＴＭＬ書式<br>
ポップアップ広告やJavascript、&lt;META&gt;を挿入したい場合にここに記述する。<br>
以下の記述が&lt;head&gt;〜&lt;/head&gt;内に挿入される。<br>
<textarea name="head_insert" cols=50 rows=3>$head_insert</textarea><br>
</td>
</tr>

<tr>
<td>スタイルシート</td>
<td>
<input type=radio name=style_sheet_en value=1 $style_sheet_check[1]>有効
<input type=radio name=style_sheet_en value=0 $style_sheet_check[0]>無効<br>
<textarea name="style_sheet" cols=50 rows=3>$style_sheet</textarea><br>
</td>
</tr>

<tr>
<td>&lt;body&gt;内挿入文</td>
<td>
ページ上部に表\示される文をＨＴＭＬで記述。ルールやコメント、広告やアクセスカウンタ、リンクなど記すことができます。<br>
タイトルの上
<input type=radio name=body_insert1_en value=1 $body_insert1_check[1]>有効
<input type=radio name=body_insert1_en value=0 $body_insert1_check[0]>無効<br>
<textarea name="body_insert1" cols=50 rows=3>$body_insert1</textarea><br>
タイトルの下
<input type=radio name=body_insert2_en value=1 $body_insert2_check[1]>有効
<input type=radio name=body_insert2_en value=0 $body_insert2_check[0]>無効<br>
<textarea name="body_insert2" cols=50 rows=3>$body_insert2</textarea><br>
更新時間表\示の下
<input type=radio name=body_insert3_en value=1 $body_insert3_check[1]>有効
<input type=radio name=body_insert3_en value=0 $body_insert3_check[0]>無効<br>
<textarea name="body_insert3" cols=50 rows=3>$body_insert3</textarea><br>
</td>
</tr>

<tr>
<td>時間設定</td>
<td>
<input type=radio name=localtime_en value=0 $localtime_check[0]>GMTからのオフセット
<input type=radio name=localtime_en value=1 $localtime_check[1]>ローカルタイム<br>
GMTからのオフセットに設定した場合、GMTより<input type=text name=offset_from_gmt value="$offset_from_gmt" size=2>時間(日本：+9時間)
</td>
</tr>

<tr>
<td>&nbsp;</td>
<td>
<input type=submit name=setupsub value="設定">
</td>
</tr>

</table>

</form>

SETUPWIN
    &ending;
}

##############################　セットアップ作成　############################
sub wrsetup {

    if ($in{'pwd'} eq "") {
	&error("管理用パスワードを正しく入れてください。");
    }
    
    if (!&checkcrypt($in{pwd},&adminpwd)){
	&error("パスワードが違います。");
    }
    
    my @nodecode=('style_sheet',
		  'head_insert',
		  'body_insert1',
		  'body_insert2',
		  'body_insert3',
		  );
    foreach (@nodecode){
	$in{$_} =~ s/<br>/\n/g;
	$in{$_} =~ s/&lt;/</g;
	$in{$_} =~ s/&gt;/>/g;
	$in{$_} =~ s/&#44;/,/g;
    }
    
    open(FILE,"> $setupfile") || error('$セットアップファイルを作成できません。$setupfileのディレクトリのパーミッションを確認してください。');
    
    print FILE <<END;
############# 環境設定ここから ########################

\$dldir = '$in{dldir}';
\$dllistfile = '$in{dllistfile}';

# バックグラウンド設定
\$bgimage_en = $in{bgimage_en};
\$bgimagefile= '$in{bgimagefile}';
\$bgcolor= '$in{bgcolor}';

#タイトル
\$title = '$in{title}';

#トップへのリンク
\$toplink_en = $in{toplink_en};
\$toplink_link = '$in{toplink_link}';
\$toplink_title = '$in{toplink_title}';

# リンククリック時 0:同じウィンドウ、1:別ウィンドウ、2:指定拡張子のみ別ウィンドウ
\$link_target = $in{link_target};
\$link_extention = '$in{link_extention}';  # 半角スペースで区切る

# アップロード禁止な拡張子
\$prohibit_en = $in{prohibit_en};
\$prohibit_extention = '$in{prohibit_extention}';  # 半角スペースで区切る

#アップファイル最大サイズ(ＭＢ)
\$maxsize2 = $in{maxsize2};

#メンバー用パスワード 1:on 0:off
\$member_only = $in{member_only};
\$member_pwd = '$in{member_pwd}';

#スタイルシート
\$style_sheet_en = $in{style_sheet_en};
\$style_sheet = '$in{style_sheet}';

#ページ上部に表\示させる文 1:on, 0:off
\$body_insert1_en = $in{body_insert1_en};
\$body_insert1 = '$in{body_insert1}';
\$body_insert2_en = $in{body_insert2_en};
\$body_insert2 = '$in{body_insert2}';
\$body_insert3_en = $in{body_insert3_en};
\$body_insert3 = '$in{body_insert3}';

#<head>挿入文
\$head_insert_en = $in{head_insert_en};
\$head_insert = '$in{head_insert}';

#時間設定
\$localtime_en = $in{localtime_en};
\$offset_from_gmt = $in{offset_from_gmt};

############# 環境設定ここまで ########################

1;

END

    close(FILE);
    
    print "Location: $script\n\n";
}

##############################　表示　################################
sub display {
    open(FILE,"< $dllistfile");
    my @alldata=<FILE>;
    close(FILE);
    
    my ($d_dev,$d_ino,$d_mode,$d_nlink,$d_uid,$d_gid,$d_rdev,$d_size,$d_atime,$d_mtime,$d_ctime,$d_blksize,$d_blocks)=stat("$dllistfile");
    my @monarray=('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)= $localtime_en ? localtime($d_mtime) : gmtime($d_mtime+$offset_from_gmt*3600);
    my $date_str = sprintf("%s %02d, %s",$monarray[$mon], $mday, $year+1900);
    
    &beginning;
    &header($date_str);
    
    my @extlist = split(/\s+/,$link_extention);
    
    if ($toplink_en == 1){
	print "<a href=\"$toplink_link\">$toplink_title</a>\n";
    }
    print "<hr>\n";
    print "<ul>\n";
    foreach (reverse(@alldata)){
	chomp;
	my ($count,$file,$title,$size,$update,$pwd)=split(/,/);
	
	my $target;
	my $ext;
	if ($link_target == 0){
	    $target = "";
	} elsif ($link_target == 1){
	    $target = "target=\"_blank\"";
	} elsif ($link_target == 2){
	    my ($body_name, $path_name, $ext) = fileparse($file,@extlist);
#	    $ext =~ s/^.+\.(.+)$/$1/;
#	    if (grep(/^$ext$/i, @extlist)){
	    if ($ext){
		$target = "target=\"_blank\"";
	    } else {
		$target = "";
	    }
	}
	
	print "<li>";
	print "<a href=\"$dldir/$file\" $target>$title</a> ($size)";
#	if ($update eq ''){
	    ($d_dev,$d_ino,$d_mode,$d_nlink,$d_uid,$d_gid,$d_rdev,$d_size,$d_atime,$d_mtime,$d_ctime,$d_blksize,$d_blocks)=stat("$dldir/$file");
	    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)= $localtime_en ? localtime($d_mtime) : gmtime($d_mtime+$offset_from_gmt*3600);
	    $update = sprintf("%s年%s月%s日%02s時%02s分",$year+1900,$mon+1,$mday,$hour,$min);
#	}
	print " <font color=\"gray\">.......... $update</font>";
	print "</li>\n";
	
    }
    print "</ul>\n";
    
    print "<hr>\n";
    
    print <<"EOM";
<form action="$script" method="POST" enctype="multipart/form-data">
<input type=hidden name=mode value=register>
<table cols=2 border=0>
<tr>
<td align="right" width="20%" nowrap>タイトル</td>
<td><input type=text name=sub size="50"></td>
</tr>
<tr>
<td align="right" width="20%" nowrap>アップファイル</td>
<td><input type=file name=upfile size="50"></td>
</tr>
<tr>
<td align="right" width="20%" nowrap>アップ後のファイル名</td>
<td><input type=text name=fname size="50"><input type=submit value="送信する"></td>
</tr>
EOM

if ($member_only == 1){
print <<END3;
<tr>
<td align="right" width="20%" nowrap>メンバー専用パスワード</td>
<td><INPUT type=\"password\" size=\"20\" name=\"member_pwd\"></td>
</tr>
END3
}

    print <<EOM2;
<tr>
<td align="right" width="20%" nowrap>削除用パスワード</td>
<td><input type=text name=pwd size="20"></td>
</tr>
</table>
</form>
EOM2

print <<NOTICE;
<font size=-1>
<font color="red">※</font>アップ後のファイル名は半角英数、アンダースコア(_)、ドット(.)、ハイフン(-)のみ受け付けます。<br>
<font color="red">※</font>アップ後のファイル名を省略すると元のファイルと同じ名前でアップされます。<br>
<font color="red">※</font>アップできる最大ファイルサイズは$maxsizeです。<br>
<font color="red">※</font>アップロードはファイルサイズ、通信速度によってそれなりに時間がかかりますので、アップロード中はこのページが再表\示されるまで根気よくお待ちください。<br>
<font color="red">※</font>削除用パスワードは半角英数で。<br>
</font>
NOTICE

    print "<hr>";
    print "<form action=\"$script\" method=\"POST\">\n";
    print "<input type=hidden name=mode value=\"delete\">\n";
    print "<select name=\"deletefile\">\n";
    print "<option value=\"0\">削除するタイトルを選んでください\n";
    foreach (reverse(@alldata)){
        chomp;
        my ($count,$file,$title,$size,$update,$pwd)=split(/,/);
        print "<option value=\"$count\">$title\n";
    }
    print "</select>\n";
    print "<input type=submit name=\"delsub\" value=\"削除する\"><br>\n";
    print "削除用パスワード<input type=password name=\"pwd\" size=\"20\">\n";
    print "</form>";

    print <<NOTICE;
<font size=-1>
<font color="red">※</font>削除はサーバーから完全にファイルを削除します。復帰はできません。<br>
<font color="red">※</font>削除用パスワードは半角英数で。<br>
</font>
NOTICE
	
print <<SETUPDISP;
<hr>
<form action="$script" method="POST">
<input type=hidden name=mode value="setup">
管理用パスワード<input type=password name=pwd>
<input type=submit name=pwdsub value="セットアップ">
</form>
<hr>
SETUPDISP

    &ending;
}

sub beginning {
#    print "Content-Type: text/html\n\n";
    print $q->header(-charset=>"$charset");
    print "<html>";
    print <<HEADPRINT;
<HEAD>
   <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=$charset">
   <META NAME="Author" CONTENT="Hideki Kanayama">
   <TITLE>$title</TITLE>
HEADPRINT

if ($head_insert_en == 1){
    print "$head_insert";
}
    
    if ($style_sheet_en == 1){
	print "<STYLE type=\"text/css\">\n";
	print "$style_sheet\n";
	print "</style>\n";
    }
    
    print "</HEAD>\n";
    print "<BODY TEXT=\"#000000\" $bgset LINK=\"#0000EE\" VLINK=\"#551A8B\" ALINK=\"#FF0000\">\n";
}

sub ending {
    undef $q;
    my $year = $lastmodifiedyear;
    if ($year > 2002){
	$year = "2002-$year";
    }
    my $mysite = ('http://www.hidekik.com/','http://www.hidekik.com/en/')[$lang];
    print "<div align=\"right\"><i>updown.cgi Ver. $version<br>Copyright(c) $year, <a href=\"$mysite\" target=\"_blank\">hidekik.com</a></i></div>\n";
    print "</body>";
    print "</html>";
    exit;
}

sub header {
    my $date_str = shift;
    print "$body_insert1" if ($body_insert1_en);
    print "<h2><CENTER><font color=\"blue\">$title</font></CENTER></h2>\n";
    print "$body_insert2" if ($body_insert2_en);
    print "<center><FONT COLOR=\"#3333FF\">Last Update :</FONT> <FONT COLOR=\"#CC0000\">$date_str</FONT></center><br>\n";
    print "$body_insert3" if ($body_insert3_en);
}

sub error {
    &beginning;
    print "<br><center>$_[0]</center>\n";
    &ending;
}

sub makecrypt {
    my $plain = shift;
    my $salt = join "", ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64, rand 64];
    my $result = crypt($plain,$salt) or crypt($plain,'$1$'.$salt.'$');
    return $result;
}

sub setadminpwd {
    &beginning;
    print "<form name=\"setpwd\" action=\"$script\" method=\"post\">";
    
    print "<center>管理者用パスワードを設定してください。<br>";
    print "<input type=input name=\"pwd\" size=20>";
    print "<input type=submit name=\"sub\" value=\"設定\">";
    print "<input type=hidden name=\"mode\" value=\"adminpwd\">";
    
    print "</form></center>";
    &ending;
}

sub wradminpwd {
    my $passwd = &makecrypt($in{pwd});
    
    if (open(FILE,"> $admindat")){
	print FILE "$passwd";
	close(FILE);
    } else {
	&error('パスワードファイル作成に失敗しました。');
    }
    print "Location: $script\n\n";
}

sub checkcrypt {
    my ($pwd,$encpwd)=@_;
    return(crypt($pwd,$encpwd) eq "$encpwd");
}

sub adminpwd {
    open(ADMIN,"< $admindat");
    my $adminpwd = <ADMIN>;
    close(ADMIN);
    return $adminpwd;
}
