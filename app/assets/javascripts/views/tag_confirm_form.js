$(document).on('submit', '.js-tag-confirm-form', function(evt) {

  evt.preventDefault();
  var form = evt.currentTarget;
  var button = form.querySelector(':focus');
  if (!button) return;

  var formData = $(evt.currentTarget).serializeArray().reduce(function(memo, f) {
    memo[f.name] = f.value;
    return memo;
  }, { intent: button.value });

  $.ajax({
    url: form.action,
    method: "post",
    data: formData,
    success: function(data) {
      var $form = $(form);
      $form.replaceWith(data.tag);
      $form.remove();
    },
    error: function() {

    }
  });
});