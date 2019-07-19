document.addEventListener('turbolinks:load', function () {
  $('.destroy_dsym').click(function () {
    var dsym_id = $(this).data('id');
    var that = $("#dsym-info-" + dsym_id);
    var href = that.find('.dsym-title');
    var app_name = href.html();
    var version = that.find('.dsym-version').text();
    var elm = $('#destory_modal');
    elm.find('.empty-content').html(app_name + " v" + version).addClass('text-danger');
    elm.find('a').attr('href', "/dsyms/" + dsym_id);
    elm.modal('toggle');
  });
});