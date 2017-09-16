ModalWindow = (function() {

  var $modal;

  return {
    open: function(content) {
      this.close();
      $modal = $('<div class="modal-overlay js-close"><div class="modal-window"></div></div>');
      $modal.find('.modal-window').html(content).append('<button class="modal-window--close js-close">×</button>');
      return $modal.appendTo('body').on('click', function(evt) {
        if (/js-close/.test(evt.target.className)) {
          this.close();
        }
      }.bind(this));
    },

    close: function() {
      if ($modal) {
        $modal.remove().off();
        $modal = null;
      }
    }
  };

})();