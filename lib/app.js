(function() {
  var Rembrant, fs, libraryTemplate;
  fs = require('fs');
  Rembrant = require('./rembrant').rembrant;
  libraryTemplate = require('./models/library').libraryTemplate;
  exports.run = function() {
    var argv, cwd, lib, manager;
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
      console.log('Not implemented yet');
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
