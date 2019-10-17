$(document).on('turbolinks:load', function () {
  $('.debug-file-toggle').click(function () {
    debug_file_id = $(this).data('id');
    $('#debug-file-metadata-' + debug_file_id).toggleClass('hidden');
  })
});