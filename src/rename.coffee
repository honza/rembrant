# Rename all files in a given directory
#
# rename.renameFilesInDirectory 'test', ->
#   console.log 'Done renaming!'
#
# The pattern is as follows:
#
# YYYYMMDD_sequence.jpg
#
# e.g.
#
# 20091231_0001.jpg
#
# Note that each day will reset the sequence counter.

fs = require 'fs'
_ = require 'underscore'
async = require 'async'
exif = require './exif.coffee'

filenames = []
data = []
sorted = []
dates = {}
directory = null
globalCallback = null

readFiles = (dir) ->
    fs.readdirSync dir

getCaptureDate = (file) ->
    capture = file['Exif.Photo.DateTimeOriginal']
    captureDate = capture.split(' ')[0]
    captureDate = captureDate.replace /:/g, ''
    captureDate

sortData = ->

    for file in data
        captureDate = getCaptureDate file

        if captureDate in _.keys dates
            dates[captureDate]++
        else
            dates[captureDate] = 1

        sorted.push
            file: file
            captureDate: captureDate
            position: dates[captureDate]

    startRenaming sorted, dates

startRenaming = (filenames, dates) ->
    for file in filenames
        num = pad file.position
        newName = "#{directory}/#{file.captureDate}_#{num}.jpg"
        oldName = file.file.filename
        fs.renameSync oldName, newName

    do globalCallback

pad = (n) ->
    if n < 10
        return '000' + n

    if n < 100
        return '00' + n

    if n < 1000
        return '0' + n

    n

exports.renameFilesInDirectory = (dir, callback) ->
    directory = dir
    filenames = readFiles dir
    fullFilenames = []
    globalCallback = callback

    for file in filenames
        if file is '.DS_Store'
            continue

        fullFilenames.push "#{dir}/#{file}"

    # I wish there was an `in paralel with a limit` - concatSeries is a bit slow
    async.concatSeries fullFilenames, exif.readExif, (err, list) ->
        data = list
        do sortData
