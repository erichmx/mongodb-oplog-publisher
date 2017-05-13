#antz = require 'antz'
async = require 'async'
#logger = require('twelve').logger 'mop', 'watch'
MongoOplog = require 'mongo-oplog'
config = require '../config'

#dbURL = config.get 'mop:db:url'
#busURL = config.get 'mop:bus:url'
#busChannel = config.get('mop:bus:channel') or 'objects'

dbURL = process.env.MOP_DB_URL
busURL = process.env.MOP_BUS_URL
busChannel = process.env.MOP_BUS_CHANNEL or 'objects'

oplog = MongoOplog dbURL

#publisher = antz.publisher busURL, busChannel
#publisher.on 'close', ->
#    console.log 'Publisher closed. Stopping'
#    oplog.stop()
#publisher.on 'error', (err) ->
#    console.log 'Error received'
#    console.log err
#    oplog.stop()

opMap = {insert: 'create', update: 'update', delete: 'delete'}

watch = (op) ->
    console.log 'Watching %s on all namespaces', op
    oplog.on op, (doc) ->
        _id = if op in ['update'] then doc.o2?._id else doc.o?._id
        ns = doc.ns
        action = opMap[op]
        return unless ns and _id and action
        topic = "#{ns}.#{action}"
        payload = if op is 'create' then doc.o else {_id: _id}
        console.log topic
#        publisher.publish topic, payload

watch 'insert'
watch 'update'
watch 'delete'

stopping = false
oplog.on 'error', (err) ->
    if err.name == "MongoError" and err.message == "No more documents in tailed cursor"
      console.log 'Watch received no more documents in tailed cursor event'
    else
      console.log 'Watch received ERROR event'
      console.log err
      stop(2) unless stopping
oplog.on 'end', ->
    console.log 'Watch received end event'
    stop(3) unless stopping

stop = (code = 0) ->
    exiting = true
    async.parallel [
        (cb) -> publisher.close cb
        (cb) -> oplog.stop cb
    ], (err) ->
        console.log err if err?
        setImmediate -> process.exit if err? then 4 else code


handleSignal = (signal) ->
    console.log "Received signal #{signal}. Stopping."
    stop()
process.on 'SIGINT', handleSignal.bind null, 'SIGINT'
process.on 'SIGTERM', handleSignal.bind null, 'SIGTERM'
process.stdout.on 'error', -> stop 5

setImmediate -> oplog.tail -> console.log 'Tailing oplog'
