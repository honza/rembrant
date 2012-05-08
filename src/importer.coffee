# Importer
# --------
#
# You have just come home from shooting some pictures and you need to throw
# away the shots that are blurry, etc.  You copy your file from the memory
# card to a temporary directory somewhere and tell rembrant where they are.
# It will then go to that directory, create thumbnails and show you an
# interface that will allow you to quickly discard some pictures.  When done,
# you click a button and the keepers will be renamed, moved to your `source`
# directory, and added to you library via the `--scan` command.  All of this
# is non-destructive.  If there is a problem, rembrant will tell you.
#
# Start rembrant with:
#
# $ rembrant --import path/to/pictures

fs = require 'fs'
path = require 'path'
eco = require 'eco'
_ = require 'underscore'
thumb = require('./thumbnail.js').thumb
async = require 'async'
{exec} = require 'child_process'
{renameFilesInDirectory} = require './rename.coffee'

# A bit of code duplication from ``photo.coffee``
class Photo
    constructor: (@filename) ->
        ext = path.extname @filename
        base = path.basename @filename, ext
        @thumb = "#{base}_800#{ext}"

getTemplate = (name) ->
    fs.readFileSync __dirname + "/../views/ui/#{name}.html", "utf-8"

baseTemplate = getTemplate 'base'

render = (template, values={}) ->
    content = eco.render getTemplate(template), values
    eco.render baseTemplate, content: content

verifyImportPath = (imagePath) ->
    if imagePath[0] is '~' or imagePath[0] is '/'
        p = imagePath
    else
        p = __dirname + "/../" + imagePath

    if not path.existsSync p
        return false
    else
        return p

createTmpDir = (importPath) ->
    if not path.existsSync importPath + "/tmp"
        fs.mkdirSync importPath + "/tmp"

createDoneDir = (importPath) ->
    if not path.existsSync importPath + "/done"
        fs.mkdirSync importPath + "/done"

imagesOnly = (files) ->
    _.reject files, (file) ->
        e = path.extname file
        e not in ['.jpg', '.JPG']

getImages = (importPath) ->
    imagesOnly fs.readdirSync importPath

hasThumbs = (importPath) ->
    files = imagesOnly fs.readdirSync importPath + "/tmp"
    if files.length > 0
        true
    else
        false

copyFilesToDone = (filenames, importPath, callback) ->
    options = 
        cwd: importPath

    q = async.queue (task, callback) ->
        exec task.command, options, (err, stdout, stderr) ->
            callback()
    , 10

    q.drain = ->
        callback()

    for fn in filenames
        q.push
            command: "cp #{fn} done/#{fn}"
        , ->

renameAllPhotos = (importPath, callback) ->
    renameFilesInDirectory importPath + "/done", ->
        callback()


# Views
# ----------------------------------------------------------------------------


exports.main = (app, importPath) ->

    importPath = verifyImportPath importPath
    if not importPath
        throw 'Invalid path'
        return

    createTmpDir importPath

    if not hasThumbs importPath
        thumb
            source: importPath
            destination: importPath + "/tmp"
            suffix: '_800'
            concurrency: 4
            width: 800
        , -> console.log 'http://localhost:8888/importer'

    app.get '/importer', (req, res) ->
        # Allow user to select files
        files = getImages importPath
        files = (new Photo(f) for f in files)
        html = render 'importer',
            files: files
        res.send html

    app.post '/importer/finish', (req, res) ->
        filenames = req.body.ids
        createDoneDir importPath
        copyFilesToDone filenames, importPath, ->
            renameAllPhotos importPath, ->
                res.send 'OK'

    app.get '/importer/image/:filename', (req, res) ->
        filename = req.params.filename
        p = importPath + "/tmp/" + filename
        fs.readFile p, "binary", (err, data) ->
            res.end data, 'binary'
