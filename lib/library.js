(function() {
  var EventEmitter, Library, formatDate, fs;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  fs = require('fs');
  EventEmitter = require('events').EventEmitter;
  formatDate = function(d) {
    var date, pad, time;
    pad = function(n) {
      if (n < 10) {
        return "0" + n;
      }
      return n;
    };
    date = "" + (d.getFullYear()) + "-" + (pad(d.getMonth())) + "-" + (pad(d.getDate()));
    time = "" + (pad(d.getHours())) + ":" + (pad(d.getMinutes())) + ":" + (pad(d.getSeconds()));
    return "" + date + " " + time;
  };
  Library = (function() {
    __extends(Library, EventEmitter);
    function Library(json, root) {
      this.json = json;
      this.root = root;
      this.toJSON = __bind(this.toJSON, this);
      this.source = this.json.source;
      this.cache = this.json.cache;
      this.on('changed', __bind(function() {
        var string;
        string = JSON.stringify(this.toJSON(), null, 4);
        return fs.writeFile('library.json', string, function(err) {
          if (err) {
            return console.log("Error saving library.json.");
          }
        });
      }, this));
      this.on('makeThumbs', __bind(function() {
        var photo, _i, _len, _ref, _results;
        _ref = this.photos;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          photo = _ref[_i];
          _results.push(photo.makeThumbs());
        }
        return _results;
      }, this));
    }
    Library.prototype.toJSON = function() {
      var p;
      return {
        source: this.source,
        cache: this.cache,
        photos: (function() {
          var _i, _len, _ref, _results;
          _ref = this.photos;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            p = _ref[_i];
            _results.push(p.toJSON());
          }
          return _results;
        }).call(this)
      };
    };
    return Library;
  })();
  exports.Library = Library;
  exports.libraryTemplate = function() {
    var now, template;
    now = new Date;
    template = {
      source: "source",
      cache: "cache",
      lastModified: formatDate(now)
    };
    return JSON.stringify(template, null, 4);
  };
}).call(this);
