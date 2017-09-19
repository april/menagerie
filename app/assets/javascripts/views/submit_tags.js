var $form = $('#submit-tags-form')
  .on('keydown', 'input', function(evt) {
    var $input = $(evt.currentTarget);
    var $row = $input.closest('.tag-form-row');

    if ($input.val().length && !$row.next().is('.tag-form-row')) {
      var index = $row.data('row');
      var next = $row[0].outerHTML.replace(new RegExp(index, 'g'), index+1);
      $row.after(next);
    }
  })
  .on('submit', function(evt) {
    evt.preventDefault();

    var data = $form.serializeArray().reduce(function(memo, field) {
      if (/^tags/.test(field.name)) {
        if (field.value) memo.tags.push(field.value);
      } else {
        memo[field.name] = field.value;
      }
      return memo;
    }, {tags: []});

    var $bttn = $form.find('button[type="submit"]');
    $bttn.prop('disabled', true);

    $.ajax({
      url: $form.attr('action'),
      method: 'post',
      data: data,
      success: function(data) {
        $form.hide().after(data.form);
      },
      error: function(xhr) {
        $bttn.prop('disabled', false).after(xhr.responseJSON.error);
      }
    });
  });