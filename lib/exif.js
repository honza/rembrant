(function() {
  var exec, fs, spawn, _, _ref;

  fs = require('fs');

  _ = require('underscore');

  _ref = require('child_process'), spawn = _ref.spawn, exec = _ref.exec;

  exports.readExif = function(filename, callback) {
    return exec("exiv2 -p a print " + filename, function(err, stdout, stderr) {
      var data, good, key, line, lines, parts, value, _i, _len;
      lines = stdout.split('\n');
      data = {
        filename: filename
      };
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        parts = line.split(' ');
        parts = _.without(parts, '');
        if (parts.length === 0) continue;
        key = parts[0];
        good = parts.slice(3, parts.length);
        value = good.join(' ');
        data[key] = value;
      }
      return callback(null, data);
    });
  };

  exports.readExifImage = function(image, callback) {
    if (!image.exif) {
      callback(null, image);
      return;
    }
    return exec("exiv2 -p a print " + image.dir + "/" + image.filename, function(err, stdout, stderr) {
      var data, good, key, line, lines, parts, value, _i, _len;
      lines = stdout.split('\n');
      data = {};
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        parts = line.split(' ');
        parts = _.without(parts, '');
        if (parts.length === 0) continue;
        key = parts[0];
        good = parts.slice(3, parts.length);
        value = good.join(' ');
        data[key] = value;
      }
      image.exif = data;
      return callback(null, image);
    });
  };

}).call(this);