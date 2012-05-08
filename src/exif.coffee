# Get EXIF data for a file
#
# readExif 'filename', (data) ->
#

fs = require 'fs'
_ = require 'underscore'
{spawn, exec} = require 'child_process'

exports.readExif = (filename, callback) ->
    exec "exiv2 -p a print #{filename}", (err, stdout, stderr) ->

        lines = stdout.split '\n'
        data =
            filename: filename

        for line in lines
            parts = line.split ' '
            parts = _.without parts, ''
            if parts.length is 0
                continue
            key = parts[0]
            good = parts[3...parts.length]
            value = good.join ' '
            data[key] = value

        callback null, data


exports.readExifImage = (image, callback) ->

    if not image.exif
        callback null, image
        return

    exec "exiv2 -p a print #{image.dir}/#{image.filename}", (err, stdout, stderr) ->

        lines = stdout.split '\n'

        data = {}

        for line in lines
            parts = line.split ' '
            parts = _.without parts, ''
            if parts.length is 0
                continue
            key = parts[0]
            good = parts[3...parts.length]
            value = good.join ' '
            data[key] = value

        image.exif = data

        callback null, image
