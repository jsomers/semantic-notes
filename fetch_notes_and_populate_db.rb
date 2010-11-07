require 'rubygems'
require 'sqlite3'
require 'htmlentities'
require 'date'
require 'json'
require 'pp'

class Date
  def to_gm_time
    to_time(new_offset, :gm)
  end

  def to_local_time
    to_time(new_offset(DateTime.now.offset-offset), :local)
  end

  private
  def to_time(dest, method)
    #Convert a fraction of a day to a number of microseconds
    usec = (dest.sec_fraction * 60 * 60 * 24 * (10**6)).to_i
    Time.send(method, dest.year, dest.month, dest.day, dest.hour, dest.min,
              dest.sec, usec)
  end
end

coder = HTMLEntities.new
def get_posts(start, num)
  raw = `/usr/bin/curl http://jsomers.tumblr.com/api/read/json -d num=#{num} -d start=#{start} -d debug=1 -s`
  return JSON.parse(raw.gsub("var tumblr_api_read = ", "").gsub("}]};", "}]}"))
end

posts = []
total = get_posts(0, 1)["posts-total"]

i = 0
while i <= total.to_i
  batch = get_posts(i, 50)
  batch["posts"].each do |post|
    posts << [post["date"], post["url"], coder.decode(post["regular-body"])]
  end
  i += 50
  puts "Fetched #{i} notes total."
end

db = SQLite3::Database.new( "notes.db" )

posts.each do |post|
  datetime = DateTime.parse(post[0]).to_time.to_i
  permalink = post[1]
  content = post[2]
  db.execute( "insert into notes(content, permalink, created_at) values ( ?, ?, ? )", content, permalink, datetime)
end