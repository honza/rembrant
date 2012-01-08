(function() {
  var async, data, dates, directory, exif, filenames, fs, getCaptureDate, globalCallback, pad, readFiles, sortData, sorted, startRenaming, _,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  fs = require('fs');

  _ = require('underscore');

  async = require('async');

  exif = require('./exif.coffee');

  filenames = [];

  data = [];

  sorted = [];

  dates = {};

  directory = null;

  globalCallback = null;

  readFiles = function(dir) {
    return fs.readdirSync(dir);
  };

  getCaptureDate = function(file) {
    var capture, captureDate;
    capture = file['Exif.Photo.DateTimeOriginal'];
    captureDate = capture.split(' ')[0];
    captureDate = captureDate.replace(/:/g, '');
    return captureDate;
  };

  sortData = function() {
    var captureDate, file, _i, _len;
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      file = data[_i];
      captureDate = getCaptureDate(file);
      if (__indexOf.call(_.keys(dates), captureDate) >= 0) {
        dates[captureDate]++;
      } else {
        dates[captureDate] = 1;
      }
      sorted.push({
        file: file,
        captureDate: captureDate,
        position: dates[captureDate]
      });
    }
    return startRenaming(sorted, dates);
  };

  startRenaming = function(filenames, dates) {
    var file, newName, num, oldName, _i, _len;
    for (_i = 0, _len = filenames.length; _i < _len; _i++) {
      file = filenames[_i];
      num = pad(file.position);
      newName = "" + directory + "/" + file.captureDate + "_" + num + ".jpg";
      oldName = file.file.filename;
      fs.renameSync(oldName, newName);
    }
    return globalCallback();
  };

  pad = function(n) {
    if (n < 10) return '000' + n;
    if (n < 100) return '00' + n;
    if (n < 1000) return '0' + n;
    return n;
  };

  exports.renameFilesInDirectory = function(dir, callback) {
    var file, fullFilenames, _i, _len;
    directory = dir;
    filenames = readFiles(dir);
    fullFilenames = [];
    globalCallback = callback;
    for (_i = 0, _len = filenames.length; _i < _len; _i++) {
      file = filenames[_i];
      if (file === '.DS_Store') continue;
      fullFilenames.push("" + dir + "/" + file);
    }
    return async.concatSeries(fullFilenames, exif.readExif, function(err, list) {
      data = list;
      return sortData();
    });
  };

}).call(this);
