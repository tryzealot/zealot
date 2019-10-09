document.addEventListener('turbolinks:load', function () {
  $('.destroy-debug-file').click(function () {
    var debug_id = $(this).data('id');
    var that = $("#debug-file-info-" + debug_id);
    var href = that.find('.debug-file-title');
    var app_name = href.html();
    var version = that.find('.debug-file-version').text();
    var elm = $('#destory_modal');
    elm.find('.empty-content').html(app_name + " v" + version).addClass('text-danger');
    elm.find('a').attr('href', "/debug_file/" + debug_id);
    elm.modal('toggle');
  });
});