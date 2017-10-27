$(document).on('submit', '.js-tag-approval-form', function(evt) {

  evt.preventDefault();
  var form = evt.currentTarget;
  var button = form.querySelector(':focus');
  if (!button) return;

  var formData = $(evt.currentTarget).serializeArray().reduce(function(memo, f) {
    memo[f.name] = f.value;
    return memo;
  }, { "tag[intent]": button.value });

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