# node-thumbnail
# (c) 2011 Honza Pokorny
# Licensed under BSD
# https://github.com/honza/node-thumbnail

fs = require 'fs'
path = require 'path'
crypto = require 'crypto'

im = require '../vendor/node-imagemagick/imagemagick'
async = require 'async'
_ = require 'underscore'

defaults =
    suffix: '_thumb'
    digest: false
    hashingType: 'sha1'
    width: 800
    concurrency: 2

extensions = [
    '.jpg'
    '.jpeg'
    '.JPG'
    '.JPEG'
    '.png'
    '.PNG'
]


createQueue = (settings) ->
    queue = async.queue (task, callback) ->
        if settings.digest
            hash = crypto.createHash settings.hashingType
            stream = fs.ReadStream task.options.srcPath

            stream.on 'data', (d) -> hash.update(d)

            stream.on 'end', ->
                d = hash.digest('hex')

                task.options.dstPath = settings.destination + '/' + d + '_' +
                    settings.width + path.extname(task.options.srcPath)

                im.resize task.options, (err, stdout, stderr) -> callback()
        else
            name = task.options.srcPath
            ext = path.extname name
            base = path.basename name, ext

            task.options.dstPath = settings.destination + '/' + base +
                settings.suffix + ext

            if path.existsSync task.options.dstPath
                callback()
            else
                im.resize task.options, (err, stdout, stderr) -> callback()

    , settings.concurrency

    queue.drain = ->
        if settings.done
            settings.done()
        else
            console.log 'all items have been processed'

    queue


run = (settings) ->
    images = fs.readdirSync settings.source
    images = _.reject images, (file) ->
        _.indexOf(extensions, path.extname(file)) is -1

    queue = createQueue settings

    _.each images, (image) ->
        options =
            srcPath: settings.source + '/' + image
            width: settings.width

        queue.push({options: options}, -> console.log image)


exports.thumb = (options, callback) ->

    if options.args

        if options.args.length isnt 2
            console.log 'Please provide a source and destination directories.'
            return

        options.source = options.args[0]
        options.destination = options.args[1]

    if path.existsSync(options.source) and path.existsSync(options.destination)
        settings = _.defaults options, defaults
    else
        console.log "Origin or destination doesn't exist."
        return

    if callback
        settings.done = callback

    run settings
