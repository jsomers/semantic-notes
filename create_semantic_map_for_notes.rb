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

# Get the post IDs (last part of permalink) and raw text,
# downcased and stripped of HTML tags and symbols.
notes = notes.collect {|n| 
  [
    n.last.split("/").last.to_i, 
    n[2]
      .downcase
      .gsub(/<\/?[^>]*>/, "")
      .gsub(/[^a-zA-Z0-9\-\s]/, "")
  ]
}

index = {} # Maps from each post ID to a list of words in that post.
reverse_index = {} # Maps from each word to a list of posts containing it.

# Rip through the notes and build those indexes.
notes.each do |doc|
  id = doc[0]
  words = doc[1].split(/\s+/)
  
  index[id] = words
  
  words.each do |term|
    (reverse_index[term] ||= []) << id
  end
end

def tf(term, doc, index)
  "Normalized term frequency within a document"
  num = index[doc].count(term)
  denom = index[doc].length.to_f
  num / denom
end

def idf(term, index, reverse_index)
  "Inverse document frequency of a term"
  num = index.keys.length
  denom = reverse_index[term].length.to_f
  Math::log(num / (denom + 1))
end

def tf_idf(term, doc, index, reverse_index)
  tf(term, doc, index) * idf(term, index, reverse_index)
end

semantics = {} # Maps words to a set [tf-idf weight of word in doc, docID] pairs.
index.each do |doc, words|
  p doc
  words.uniq.collect {|w| [tf_idf(w, doc, index, reverse_index), w]}.each do |pair|
    word = pair[1]
    weight = pair[0]
    (semantics[word] ||= []) << [weight, doc]
  end
end

ObjectStash.store semantics, './semantics.stash'
