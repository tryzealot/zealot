document.addEventListener('turbolinks:load', function () {
  $('.destroy-debug-file').click(function () {
    var debug_id = $(this).data('id');
    var that = $("#debug-file-info-" + debug_id);
    var href = that.find('.debug-file-title');
    var app_name = href.html();
    var device_type = that.find('.debug-file-device-type').html();
    var version = that.find('.debug-file-version').text();
    var elm = $('#destory_modal');

    elm.find('.empty-content').html(function () {
      var tips = "删除确认：";
      var conform_text = "<span class='text-danger'>" + app_name + "(" + device_type + ") v" + version + "</span>";

      return tips + conform_text;
    });

    elm.find('a').attr('href', "/debug_file/" + debug_id);
    elm.modal('toggle');
  });
});