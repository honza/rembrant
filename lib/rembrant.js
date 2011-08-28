(function() {
  var Model;
  Model = (function() {
    function Model() {}
    Model.prototype.run = function() {
      return console.log('Hello');
    };
    return Model;
  })();
}).call(this);
