(function() {
  var App, Photo;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Photo = (function() {
    function Photo(json) {
      this.id = json.id;
      this.filename = json.filename;
      this.sha = json.sha;
      this.albumId = json.album_id;
    }
    Photo.prototype.render = function() {
      return "<div class=\"photo\">\n  <img src=\"/photo/" + this.sha + "_800.jpg\" />\n</div>";
    };
    return Photo;
  })();
  App = (function() {
    function App() {
      this.el = $('#photos');
    }
    App.prototype.run = function() {
      return $.getJSON('/photos', null, __bind(function(response) {
        var p, photo, _i, _len, _results;
        console.log(response);
        _results = [];
        for (_i = 0, _len = response.length; _i < _len; _i++) {
          photo = response[_i];
          p = new Photo(photo);
          _results.push(this.el.append(p.render()));
        }
        return _results;
      }, this));
    };
    return App;
  })();
  $(function() {
    var app;
    app = new App;
    return app.run();
  });
}).call(this);
