remotedb = new PouchDB 'https://couch.samgentle.com/docs-nodejs-5-4-0'
db = new PouchDB 'local'
$ = document.querySelector.bind(document)

FIELDS = ['module', 'name', 'content']

window.db = db

$('#results').innerHTML = 'Loading...'

remotedb.replicate.to(db).then ->
  $('#results').innerHTML = 'Building indexes...'
  db.search
    fields: FIELDS
    build: true
.then ->
  db.put {
    _id: '_design/search_index'
    views:
      search_index:
        map: ((doc) -> emit doc.name.toLowerCase(); emit doc._id.toLowerCase()).toString()
  }
.catch (e) -> throw e unless e.status is 409 #Ignore conflicts - index already exists
.then ->
  db.query 'search_index'
.then ->
  $('#results').innerHTML = 'Ready.'
  console.log "READY!"

resultsEl = $('#results')

genResult = (doc) ->
  """
    <h2>#{doc.title}</h2>
    <div>#{doc.content}</div>
  """

$('#search').addEventListener 'input', ->
  # dots and such to slashes so we match console.log -> Console/log
  query = $('#search').value
  key = query.toLowerCase().replace(/\W/,'/')
  key ||= '\uFFFF' # make the empty key not return anything

  Promise.all [
    db.query 'search_index',
      startkey: key
      endkey: key + '\uFFFF'
      include_docs: true
      limit: 5

    db.search
      fields: FIELDS
      query: query
      include_docs: true
      #highlighting: true
      limit: 5
  ]

  .then ([direct_results, fulltext_results]) ->
    results = []
    resultsmap = {}
    for result in direct_results.rows.concat(fulltext_results.rows) when !resultsmap[result.id]
      results.push result
      resultsmap[result.id] = true

    console.log "results", results
    resultsEl.innerHTML = ""
    for result in results
      div = document.createElement 'div'
      div.innerHTML = genResult result.doc
      console.log "div", div
      resultsEl.appendChild div
  .catch (e) -> console.error "Query failed", e
