var $form = $('#tag-submit-form')
  .on('keydown', 'input', function(evt) {
    var $input = $(evt.currentTarget);
    var $row = $input.closest('.js-expanding-form-row');

    if ($input.val().length && !$row.next().is('.js-expanding-form-row')) {
      var index = $row.data('row');
      var next = $row[0].outerHTML.replace(new RegExp(index, 'g'), index+1);
      $row.after(next);
    }
  })
  .on('submit', function(evt) {
    evt.preventDefault();

    var $bttn = $form.find('button[type="submit"]');
    $bttn.prop('disabled', true);

    $.ajax({
      url: $form.attr('action'),
      method: 'post',
      data: $form.serialize(),
      success: function(data) {
        $form.hide().after(data.form);
      },
      error: function(xhr) {
        $bttn.prop('disabled', false).after(xhr.responseJSON.error);
      }
    });
  });