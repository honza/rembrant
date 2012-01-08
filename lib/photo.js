(function() {
  var Photo, path;

  path = require('path');

  Photo = (function() {

    function Photo(filename, dir, albums, exif) {
      this.filename = filename;
      this.dir = dir;
      this.albums = albums != null ? albums : [1];
      this.exif = exif != null ? exif : {};
    }

    Photo.fromJSON = function(json) {
      var p;
      return p = new Photo(json.filename, json.dir, json.albums, json.exif);
    };

    Photo.prototype.getHtmlName = function() {
      var base;
      base = path.basename(this.filename, '.jpg');
      return base + '.html';
    };

    Photo.prototype.getThumb = function(width) {
      var base;
      base = path.basename(this.filename, '.jpg');
      return "" + base + "_" + width + ".jpg";
    };

    return Photo;

  })();

  exports.Photo = Photo;

}).call(this);
