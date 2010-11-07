
motivation: lots of notes, wanted input easy, consequence is that they're not categorized. can i do it automatically?

let's take a shot. approach:

1. drop everything in a database (tumblr api call, sqlite3)
2. clean up words
3. tf-idf [explain how this works]
	a. build index
	b. build reverse index
	c. write functions
4. create index mapping words to documents
5. serialize (like pickle) that object
6. quick-and-dirty results builder
7. discuss results. "female", "math" are good examples. "economics" not as good. remember how tf-idf works (short docs favored).
8. extensions: live search; wikipedia vector semantic relatedness clusters; live suggestions on new text (say, as i'm writing something).