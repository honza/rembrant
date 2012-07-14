_ = require 'underscore'
async = require 'async'
crypto = require 'crypto'
fs = require 'fs'
path = require 'path'

cloudfiles = require 'cloudfiles'
knox = require 'knox'
findit = require 'findit'

class CDN

    constructor: (@type, @cwd, @name, @secret, @bucket) ->
        switch @type
            when 'cloudfiles'
                @client = cloudfiles.createClient
                    auth:
                        username: @name
                        apiKey: @secret
            when 'aws'
                @client = knox.createClient
                    key: @name
                    secret: @secret
                    bucket: @bucket
            else
                console.log "Not implemented"

    uploadFile: (filename, callback) =>
        console.log "Uploading #{filename}"

        if @bucket is 'undefined'
            throw "Undefined bucket"

        options =
            remote: path.basename(filename)
            local: filename

        @client.putFile(filename, path.basename(filename), (err, uploaded) -> callback())

    uploadFiles: (files, done) ->
        client = @client
        cwd = @cwd

        queue = async.queue (task, callback) =>
            @uploadFile task.filename, callback
        , 10

        queue.drain = ->
            console.log 'all files uploaded'
            done()

        for file in files
            queue.push filename: file

createQueue = (finished) ->

    data = {}

    queue = async.queue (task, callback) ->
        getSha task.filename, (hash) ->
            data[task.filename] = hash
            callback()
    , 5

    queue.drain = ->
        console.log 'all shas done'
        finished data

    queue

getSha = (filename, callback) ->
    hash = crypto.createHash 'sha1'
    stream = fs.ReadStream filename
    stream.on 'data', (d) -> hash.update(d)
    stream.on 'end', -> callback hash.digest('hex')

getBuildFiles = (library, cwd) ->
    build = "#{cwd}/build"

    files = findit.sync(build)
    _.reject files, (f) ->
        fs.statSync(f).isDirectory()

exports.deploy = (library, cwd) ->

    {key, secret, bucket, type} = library.deploy

    if not secret
        console.log 'Missing secret'
        return
    if not key
        console.log 'Missing key'
        return
    if not bucket
        console.log 'Missing bucket'
        return
    if not type
        console.log 'Missing type'
        return


    # Ensure build

    cdn = new CDN('aws', cwd, key, secret, bucket)

    if path.existsSync "s3map.json"
        map = JSON.parse fs.readFileSync "s3map.json", "utf-8"
    else
        map = {}

    files = getBuildFiles(library, cwd)
    difference = _.difference files, _.keys map

    console.log difference

    q = createQueue (data) ->

        for fn, hash of map
            if data[fn] isnt hash
                difference.push fn


        cdn.uploadFiles difference, ->
            console.log 'done all'
            for f in _.keys data
                map[f] = data[f]
            fs.writeFileSync "s3map.json", JSON.stringify(map, null, 4), "utf-8"

    for f in files
        q.push filename: f
