// This file handles the sorting of images just imported from a camera

(function($) {

  $(function() {

    $('.icon').click(function() {
      $(this).parent().remove();
    });

    $('#done').click(function() {
      var images = $('.image');
      var ids = [];
      for (var i=0; i < images.length; i++) {
        ids.push(images[i].id);
      }

      $.post('/importer/finish', {ids: ids}, function(data) {
        if (data === 'OK') {
          alert('All done.');
        }
      });

    });
  });

})(jQuery);
