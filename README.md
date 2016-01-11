Docs in a box!
==============

This is a simple proof of concept for instant searching reference documentation. The idea is that you can add whatever APIs you're using to docs-in-a-box and then quickly search for function references rather than ending up with a thousand tabs.

It's all built on CouchDB and PouchDB, so it's offline-friendly by default. Each documentation source could be its own separate CouchDB, and they don't need to be hosted in the same place as docs-in-a-box. The one in this demo is [the NodeJS API docs](https://couch.samgentle.com/docs-nodejs-5-4-0/) hosted on my server.

The search is a combination of prefix-matching and fulltext search (TF-IDF) via [pouchdb-quick-search](https://github.com/nolanlawson/pouchdb-quick-search).