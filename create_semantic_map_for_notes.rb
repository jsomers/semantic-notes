require 'sqlite3'
require 'date'
require 'stash'

class Array
  def count(t)
    self.length - (self - [t]).length
  end
end

db = SQLite3::Database.open( "notes.db" )
notes = db.execute("select * from notes;")

notes = notes.collect {|n| [n.last.split("/").last.to_i, n[2].downcase.gsub(/<\/?[^>]*>/, "").gsub(/[^a-zA-Z0-9\-\s]/, "")]}

index = {}
reverse_index = {}
notes.each do |doc|
  id = doc[0]
  words = doc[1].split(/\s+/)
  
  index[id] = words
  
  words.each do |term|
    if reverse_index[term]
      reverse_index[term] << id
    else
      reverse_index[term] = [id]
    end
  end
end

def tf(term, doc, index)
  num = index[doc].count(term)
  denom = index[doc].length.to_f
  num / denom
end

def idf(term, index, reverse_index)
  num = index.keys.length
  denom = reverse_index[term].length.to_f
  Math::log(num / (denom + 1))
end

def tf_idf(term, doc, index, reverse_index)
  tf(term, doc, index) * idf(term, index, reverse_index)
end

semantics = {}
index.each do |doc, words|
  p doc
  words.uniq.collect {|w| [tf_idf(w, doc, index, reverse_index), w]}.each do |pair|
    word = pair[1]
    weight = pair[0]
    if semantics[word]
      semantics[word] << [weight, doc]
    else
      semantics[word] = [[weight, doc]]
    end
  end
end

ObjectStash.store semantics, './semantics2.stash'