(function() {
  var Rembrant, fs, libraryTemplate;
  fs = require('fs');
  Rembrant = require('./rembrant').rembrant;
  libraryTemplate = require('./models/library').libraryTemplate;
  exports.run = function() {
    var argv, cwd, lib, manager, p, x, _i, _len, _ref;
    argv = require('optimist').argv;
    if (argv.init) {
      cwd = process.cwd();
      lib = libraryTemplate();
      fs.writeFile('library.json', lib, function(err) {
        if (err) {
          return console.log('Error writing to disk.');
        }
      });
      return;
    }
    if (argv["import"]) {
      cwd = process.cwd();
      manager = new Rembrant(cwd);
      manager.run();
      return;
    }
    if (argv.scan) {
      manager = new Rembrant(cwd);
      manager.load();
      console.log(manager.library);
      _ref = manager.library.albums[0].photos;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        console.log(p);
        break;
        x = JSON.parse(p);
        console.log(x.filename);
      }
      return;
    }
    if (argv["export"]) {
      console.log('Not implemented yet');
      return;
    }
    if (argv.deploy) {
      console.log('Not implemented yet');
      return;
    }
    return console.log('Unknown option');
  };
}).call(this);
