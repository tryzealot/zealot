document.addEventListener('turbolinks:load', function () {
  $('#user_use_password').on('click', function () {
    var use_password = $(this).prop('checked');
    var passwor_el = $('.user_password');
    if (use_password) {
      passwor_el.removeClass('hidden');
    } else {
      passwor_el.addClass('hidden');
      $('#user_password').val('');
    }
  })
});