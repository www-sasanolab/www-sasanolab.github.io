#!/usr/bin/ruby

print "Content-type: text/html\n\n"
require "cgi-lib"
input = CGI.new

#初期設定
FILENAME = "bbs1.log"
MAXLOG = 10
log = []

#フォームからのデータ読みこみ
senddata = input["senddata"]

#ファイルの読み込み
c = 0
fh = open(FILENAME)
fh.each{|l|
log[c] = l
c += 1
if c >= MAXLOG
break
end
}
fh.close

#ファイルの書き込み
if senddata
log.unshift("#{senddata}\n")
c = 0
fh = open(FILENAME, "w")
log.each{|l|
fh.print l
c += 1
if c >= MAXLOG
break
end
}
fh.close
end

#HTML部分
print <<EOF;
<html>
<body>
<form method="POST">
<input type="text" name="senddata" size="80">
<input type="submit" value="送信">
</form>
<hr>
EOF

log.each{|l|
print "#{l}\n<hr>\n"
}

print <<EOF;
</body>
</html>
EOF