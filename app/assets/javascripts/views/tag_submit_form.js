(function() {

  var $form = $('#tag-submit-form')
    // Tag entry expanding form
    .on('keydown', 'input', function(evt) {
      var $input = $(evt.currentTarget);
      var $row = $input.closest('.js-expanding-form-row');

      if ($input.val().length && !$row.next().is('.js-expanding-form-row')) {
        var index = $row.data('row');
        var next = $row[0].outerHTML.replace(new RegExp(index, 'g'), index+1);
        $row.after(next);
      }
    })
    // Tag submission process
    .on('submit', function(evt) {
      evt.preventDefault();

      // Pre-flight validation
      // var tags = $form.serializeArray()
      //   .map(function(field) { return field.name === 'tag_submission[tags][]' ? field.value : null; })
      //   .filter(function(value) { return !!value; });

      // if (!tags.length) {
      //   return setError('No new tags proposed');
      // } else if (!$form.find('#tag_submission_accept_terms').prop('checked')) {
      //   return setError('You must agree to the terms of service');
      // }

      // Async form submission
      var $bttn = $form.find('button[type="submit"]');
      $bttn.prop('disabled', true).prepend('<div class="hourglass"></div>');

      $.ajax({
        url: $form.attr('action'),
        method: 'post',
        data: $form.serialize(),
        success: function(data) {
          setTimeout(function() {
            $form.animate({opacity: 0}, 750, function() {
              var $confirm = $(data.form);
              $form.hide().after($confirm);
              $form.remove();
              requestAnimationFrame(function() {
                $confirm.css('opacity', 1);
              });
            });
          }, 750);
        },
        error: function(xhr) {
          $bttn.find('.hourglass').remove();
          $bttn.prop('disabled', false);
          setError(xhr.responseJSON.error);
        }
      });
    });

  // Error handling
  function setError(mssg) {
    if ($form) {
      $form.find('.tag-form-error').remove();
      $form.append('<p class="tag-form-error">'+ mssg +'</p>');
    }
  }

}());