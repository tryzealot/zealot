$(document).on('turbolinks:load', function () {
  $('.debug-file-section').click(function () {
    debug_file_id = $(this).data('id');

    console.info(debug_file_id);
    console.info($('#debug-file-metadata-' + debug_file_id).html());
    $('#debug-file-metadata-' + debug_file_id).toggleClass('hidden');
  })
});