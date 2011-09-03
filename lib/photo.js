(function() {
  var EventEmitter, Photo, crypto, fs;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  fs = require('fs');
  crypto = require('crypto');
  EventEmitter = require('events').EventEmitter;
  Photo = (function() {
    __extends(Photo, EventEmitter);
    function Photo(json) {
      this.title = json.title || "";
      this.filename = json.filename;
      this.caption = json.caption || "";
      this.album = json.album || "";
      this.sha = json.sha || this.getSHA();
      this.smallThumb = "" + this.sha + "-100.jpg";
      this.bigThumb = "" + this.sha + "-800.jpg";
    }
    Photo.prototype.getSHA = function() {
      var s, sum;
      sum = crypto.createHash('sha1');
      s = fs.ReadStream(this.filename);
      s.on('data', function(d) {
        return sum.update(d);
      });
      s.on('end', __bind(function() {
        this.sha = sum.digest('hex');
        return this.emit('done');
      }, this));
      return '';
    };
    Photo.prototype.toJSON = function() {
      return {
        title: this.title,
        filename: this.filename,
        caption: this.caption,
        album: this.album,
        sha: this.sha,
        smallThumb: this.smallThumb,
        bigThumb: this.bigThumb
      };
    };
    return Photo;
  })();
  exports.Photo = Photo;
}).call(this);
