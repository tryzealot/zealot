$(document).on('turbolinks:load', function () {
  $('.debug-file-toggle').on('click', function () {
    debug_file_id = $(this).data('id');
    $('#debug-file-metadata-' + debug_file_id).toggleClass('d-none');
    alert('dddd');
  });

  $('.destroy-debug-file').on('click', function () {
    var debug_id = $(this).data('id');
    var that = $("#debug-file-info-" + debug_id);
    var app_name = that.data('app-name');
    var device_type = that.find('.debug-file-device-type').html();
    var releas_version = that.find('.debug-file-version').text();
    var build_version = that.find('.debug-file-build-version').text();
    var elm = $('#destory_modal');

    elm.find('.empty-content').html(function () {
      var tips = "删除确认：";
      var conform_text = "<span class='text-danger'>" +
        app_name + " " + device_type +
        " v" + releas_version +
        " (" + build_version + ")"
        "</span>";

      return tips + conform_text;
    });

    elm.find('a').attr('href', $(this).data('url'));
    elm.modal('toggle');
  });
});