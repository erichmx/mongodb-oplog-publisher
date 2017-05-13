#!/usr/bin/env node


MongoOplog =require('mongo-oplog')
const oplog = MongoOplog(process.env.MOP_DB_URL)

oplog.tail();

oplog.on('op', data => {
    console.log(data);
});

oplog.on('insert', doc => {
    console.log(doc);
});

oplog.on('update', doc => {
    console.log(doc);
});

oplog.on('delete', doc => {
    console.log(doc.o._id);
});

oplog.on('error', error => {
    console.log(error);
});

oplog.on('end', () => {
    console.log('Stream ended');
});

oplog.stop(() => {
    console.log('server stopped');
});

require('coffee-script/register');
require('./lib/watch');
