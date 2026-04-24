#!/usr/bin/ruby

class Calendar #カレンダークラス作成
WeekName = [
'Su', #Sun
'Mo', #Mon
'Tu', #Tue
'We', #Wed
'Th', #Thu
'Fr', #Fri
'Sa', #Sat
]

WeekColor = [
'#ff0000', #Sun
'#000000', #Mon
'#000000', #Tue
'#000000', #Wed
'#000000', #Thu
'#000000', #Fri
'#0000ff', #Sat
]

TodayColor = '#ffff00'

TodayShellHead = "\033[7m"
TodayShellFoot = "\033[m"

def initialize(year, month) #カレンダークラス初期化
@year = year.to_i
@month = month.to_i
@wday = []
@daydata = []

if (@month < 1) || (12 < @month)
raise "Month Error"
end

if (@year < 1) || (2037 < @year)
raise "Year Error"
end

nowday = Time.local(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0)

(1..31).each do |day|
itsday = Time.local(@year, @month, day, 0, 0, 0)

@daydata[day] = 'today' if nowday == itsday

if day > 28 && itsday.month != @month
@wday[day] = nil
else
@wday[day] = itsday.wday
end
end
end

def html_print #HTML表示メソッド
print_data = "<table border=\"3\" cellspacing=\"0\" cellpadding=\"2\">\n"
print_data += "<caption>#{@year}年 #{@month}月</caption>\n"
print_data += "<tr>"
(0 .. WeekName.length - 1).each do |i|
print_data += "<th><font color=\"#{WeekColor[i]}\">#{WeekName[i]}</font></th>"
end
print_data += "</tr>\n"

(1 .. @wday.length).each do |day|
break unless @wday[day]

if day == 1
print_data += "<td></td>" * @wday[day]
elsif @wday[day] == 0
print_data += "<tr>"
end

if @daydata[day] == 'today'
print_data += "<td align=\"right\" bgcolor=\"#{TodayColor}\">"
else
print_data += "<td align=\"right\">"
end

print_data += "<font color=\"#{WeekColor[@wday[day]]}\">#{day}</font></td>"

if @wday[day] == 6
print_data += "</tr>\n"
end
end
print_data += "</table>\n"
print_data
end

def shell_print #SHELL表示メソッド
print_data = "#{@year} #{@month}".center(20) + "\n"
WeekName.each{|i| print_data += " #{i}"}
print_data += "\n"

(1 .. @wday.length).each do |day|
break unless @wday[day]

if day == 1
print_data += " " * @wday[day]
end

if @daydata[day] == 'today'
print_data += ' ' + TodayShellHead + sprintf("%2d", day) + TodayShellFoot
else
print_data += ' ' + sprintf("%2d", day)
end

if @wday[day] == 6
print_data += "\n"
end
end
print_data
end
end


year = ARGV.shift || Time.now.year
month = ARGV.shift || Time.now.month

if ENV['REQUEST_METHOD'] #HTML
print "Content-type: text/html\n\n"
print "<html><body>\n"
begin
calen = Calendar.new(year, month)
print "#{calen.html_print}\n"
rescue
print "#{$!}\n"
end
print "</body></html>\n"
else #SHELL
begin
calen = Calendar.new(year, month)
print "#{calen.shell_print}\n"
rescue
print "#{$!}\n"
end
end