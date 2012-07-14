# Rembrant - photo gallery software
# (c) 2012 - Honza Pokorny - All rights reserved
# Freely available under the terms of the BSD license
# https://github.com/honza/rembrant

fs = require 'fs'
path = require 'path'
_ = require 'underscore'
{spawn, exec} = require 'child_process'
async = require 'async'
eco = require 'eco'
thumb = require('./thumbnail').thumb
Photo = require('./photo').Photo
exif = require './exif'
rename = require './rename'
deploy = require './deploy'

baseTemplate = fs.readFileSync __dirname + "/../views/base.html", "utf-8"

library =
    source: 'test-photos'
    cache: 'cache'
    lastModified: ''
    awsKey: ''
    awsSecret: ''
    awsBucket: ''
    photos: []
    albums: [
        id: 1
        name: 'Unsorted'
    ]

class Rembrant

    constructor: (filename, @cwd) ->
        if not path.existsSync filename
            console.log "Path doesn't exist, creating..."
            @createLibrary()
            return

        @library = fs.readFileSync filename, 'utf-8'
        @library = JSON.parse @library

        photos = []

        for photo in @library.photos
            photos.push Photo.fromJSON photo

        @library.photos = photos

    addAlbum: (album) ->
        max = _.max @library.albums, (item) -> item.id
        @library.albums.push
            id: max.id + 1
            name: album
        @save()

    makeThumbs: ->

        if not path.existsSync @library.cache
            fs.mkdirSync @library.cache

        thumb
            source: @library.source
            destination: @library.cache
            suffix: '_930'
            concurrency: 4
            width: 930
        , ->
            console.log 'Done processing 800px wide thumbnails'

        thumb
            source: @library.source
            destination: @library.cache
            suffix: '_160'
            concurrency: 4
            width: 160
        , ->
            console.log 'Done processing 160px wide thumbnails'

    getPhotoById: (id) ->
        results = _.filter @library.photos, (photo) ->
            photo.id is id
        if results.length is 1
            return results[0]
        else
            return null

    createLibrary: ->
        string = JSON.stringify library, null, 4
        fs.writeFileSync 'library.json', string

    importPhotos: ->
        files = fs.readdirSync @library.source
        photos = @library.photos or []

        libraryFilenames = _.reject files, (file) ->
            e = path.extname file
            e isnt '.jpg'

        for file in libraryFilenames
            if file not in photos
                photos.push new Photo file, @library.source

        @library.photos = photos

        @ensureExif()

    ensureExif: ->
        async.concatSeries @library.photos, exif.readExifImage, (err, list) =>
            console.log list
            console.log 'done'
            @save()

    scan: ->
        files = fs.readdirSync @library.source
        newFiles = _.difference files, _.pluck @library.photos, 'filename'

        newFiles = _.reject newFiles, (file) ->
            e = path.extname file
            e isnt '.jpg'

        for file in newFiles
            console.log file
            @library.photos.push new Photo null, file

        @library.photos = _.sortBy @library.photos, (photo) -> photo.filename
        @save()
        @ensureIds()

    save: ->
        @library.lastModified = new Date
        string = JSON.stringify @library, null, 4
        fs.writeFileSync 'library.json', string

    imagesByDate: ->
        _.sortBy @library.photos, (image) ->
            image.exif['Exif.Photo.DateTimeOriginal']

    getSimpleLibrary: ->
        photos = _.map @library.photos, (i) ->
            filename: i.filename

        JSON.stringify
            albums: @library.albums
            photos: photos

    generateIndex: ->
        template = fs.readFileSync __dirname + "/../views/base.html", "utf-8"
        html = eco.render template, data: @getSimpleLibrary()
        fs.writeFileSync @cwd + "/build/index.html", html

    finalizeFile: (content, filename) ->
        rendered = eco.render baseTemplate, content: content
        fs.writeFileSync @cwd + "/build/" + filename, rendered

    copyStaticFiles: ->
        exec "rm -rf #{@cwd}/build/static"
        exec "cp -rf #{__dirname}/../static/js/* #{@cwd}/build/."
        exec "cp -rf #{__dirname}/../static/css/* #{@cwd}/build/."
        exec "cp #{@library.cache}/*.jpg #{@cwd}/build/."

    normalize: ->
        rename.renameFilesInDirectory @library.source, ->
            console.log 'done'

    removeExif: ->
        lib = []
        for p in @library.photos
            delete p.exif
            lib.push p

        @library.photos = lib
        @save()

    ensureIds: ->
        ids = p.id for p in @library.photos
        ids = _.compact ids

        if ids.length is 0
            max = 1
        else
            max = _.max ids

        for p in @library.photos
            p.id = max
            max++

        @save()

    export: ->
        if not path.existsSync @cwd + "/build"
            fs.mkdirSync @cwd + "/build"

        @generateIndex()
        @copyStaticFiles()

    deploy: ->
        deploy.deploy(@library, @cwd)

startApp = (rembrant, importPath) ->
    express = require("express")

    app = express.createServer express.bodyParser(),
        express.cookieParser(),
        express.session({secret: "cvfrFRQW352rrvf4132"})

    app.configure ->
            @set('views', __dirname + '/../views')
            @set('view engine', 'jade')
            app.use(express.static(__dirname + '/../public'))
            @use(@router)

    routes =
        index: (req, res) ->
            html = fs.readFileSync __dirname + "/../views/index.eco", "utf-8"
            res.end html

        image: (req, res) ->
            filename = req.params.filename
            p = "#{rembrant.cwd}/#{rembrant.library.cache}/#{filename}"
            fs.readFile p, "binary", (err, data) ->
                res.end data, 'binary'

        photos: (req, res) ->
            # TODO: implement in a real way
            # photos = _.clone rembrant.library.photos
            # photos = photos[0..30]
            # res.end JSON.stringify photos.reverse()
            photos = _.clone rembrant.library.photos
            # photos = photos[0..30]
            res.end JSON.stringify photos.reverse()

        updatePhoto: (req, res) ->
            id = parseInt req.params.id
            data = req.body
            photo = rembrant.getPhotoById id

            if photo
                res.send 202
                photo.albums = data.albums
                rembrant.save()
            else
                res.send 404

        albums: (req, res) ->
            res.end JSON.stringify rembrant.library.albums

        newAlbum: (req, res) ->
            name = req.body.name
            rembrant.addAlbum name
            res.send 201

    app.get '/', routes.index
    app.get '/image/:filename', routes.image

    app.get '/photos', routes.photos
    app.put '/photos/:id', routes.updatePhoto

    app.get '/albums', routes.albums
    app.post '/albums', routes.newAlbum

    # Importer
    if importPath
        importer = require('./importer').main(app, importPath)

    console.log 'Serving http://localhost:8888'
    app.listen(8888)


exports.runFromCli = ->
    program = require 'commander'

    program.version '0.0.1'
    program.option '-i, --import [path]'
    program.option '-s, --scan', 'Check if new images were added'
    program.option '-e, --export', 'Generate deployable html structure'
    program.option '-d, --deploy', 'Deploy files to CDN'
    program.option '-t, --thumbs', 'Create thumbnails for all files'
    program.option '-n, --rename', 'Rename files in your library'
    program.option '-r, --serve', 'Run the rembrant server'
    program.option '-a, --add-album <name>', 'Add an album to library'
    program.option '-m, --exif', 'Kill exif'
    program.option '-x, --ids', 'Ensure IDs'
    program.parse process.argv

    rembrant = new Rembrant 'library.json', process.cwd()

    if program.thumbs
        rembrant.makeThumbs()

    if program.scan
        rembrant.scan()

    if program.export
        rembrant.export()

    if program.deploy
        rembrant.deploy()

    if program.import and program.import is true
        rembrant.importPhotos()

    if program.import and program.import isnt true
        console.log 'importing'
        imagePath = program.import
        startApp rembrant, imagePath

    if program.rename
        rembrant.normalize()

    if program.serve
        startApp rembrant

    if program.addAlbum
        rembrant.addAlbum program.addAlbum

    if program.exif
        rembrant.removeExif()

    if program.ids
        rembrant.ensureIds()
