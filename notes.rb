require 'sqlite3'
require 'stash'

semantics = ObjectStash.load './semantics.stash'

db = SQLite3::Database.open( "notes.db" )
notes = db.execute("select * from notes;")
notes_map = {}
notes.each {|n| notes_map[n.last.split("/").last.to_i] = n[2]}

f = File.new("./output.html", "w")
f.puts '<?xml version="1.0" encoding="UTF-8"?>'
f.puts "<style type='text/css'>body {font-family: Georgia; font-size: 12.3px; line-height: 1.4em; margin-left: 20px; text-align: justify; width: 650px;} a {color: #4183C4; text-decoration: none;} a:hover {border-bottom: 1px solid #4183C4;} .tumblr-post p { margin-left: 10px; margin-right: 10px; }</style>"
semantics[ARGV[0]].sort.reverse.each do |match|
  f.puts "<div class='tumblr-post' style='border-bottom: 1px solid #ccc;'>"
  f.puts notes_map[match[1]][0..-5]
  f.puts "<span style='font-size: 12px;'> <a href='http://jsomers.tumblr.com/post/#{match[1]}'>(%.3f)</a></span>" %match[0]
  f.puts "</div>"
end
f.close