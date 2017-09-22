$(document)
  .on('mouseover', '[data-tag-status]', function(evt) {
    var $tag = $(evt.currentTarget);
    var label = $tag.data('tag-status');
    if (!label) return;

    var left = $tag.position().left + Math.round($tag.outerWidth() / 2);

    requestAnimationFrame(function() {
      $tag
        .closest('.illustration-tag')
        .prepend('<span class="js-tag-status" style="left:'+left+'px">'+label+'</span>');
    });
  })
  .on('mouseout', '[data-tag-status]', function(evt) {
    $(evt.currentTarget).closest('.illustration-tag').find(".js-tag-status").remove();
  });