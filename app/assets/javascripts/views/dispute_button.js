$(document).on('click', '[data-dispute]', function(evt) {
  evt.preventDefault();

  // Collect fields from the dispute button form:
  var $bttn = $(evt.currentTarget);
  var $form = $bttn.closest('form');
  var form_action = $form.attr('action');
  var auth_token = $form.find('input[name="authenticity_token"]').val();

  // Install form config into the modal form:
  var $el = ModalWindow.open($("#tag-dispute-form-tmpl").html());
  $el.find('form').attr('action', form_action);
  $el.find('input[name="authenticity_token"]').val(auth_token);
  $el.find('.disputed-tag').text($bttn.data('dispute'));

  // Enable captcha:
  var captcha = $el[0].querySelector('.g-recaptcha');
  grecaptcha.render(captcha, { sitekey: captcha.getAttribute('data-sitekey') });
});