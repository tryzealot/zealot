
// function build() {
//   var button = $('#build_it');
//   button.button('loading');

//   var app_job = button.data('job');
//   var url = HOST + "api/v2/jenkins/projects/" + app_job + "/build";
//   console.log('build url: ', url);

//   $.ajax({
//     url: url,
//     type: 'get',
//     dataType: 'json',
//     success: function (data) {
//       console.log(data)
//       if (data.code == 201 || data.code == 200) {
//         var url = data.url + 'console';
//         message = '请求成功！访问这里查看详情：<a href="' + url + '">' + url + '</a>';
//       } else {
//         message = '错误：' + data.message;
//       }

//       if (data.code == 201) {
//         sleep(8000);
//       }

//       $('#jekins_buld_alert').removeClass('hidden').html(message);
//     },
//     error: function (xhr, ajaxOptions, thrownError) {
//       button.button('reset');
//       //  $('#cache-info').data('key', xhr.responseJSON.cache).removeClass('hide')
//       //  $("#result")
//       //      .html('请求失败！接口返回：' + xhr.responseJSON.message)
//       //      .addClass("alert alert-danger")
//       //      .show()
//     },
//     complete: function () {
//       button.button('reset');
//     }
//   });
// }

$(document).on('turbolinks:load', function () {
  $('#download_it').click(function () {
    var wechat_regex = /MicroMessenger/i;
    var that = $('#download_it');
    if (wechat_regex.test(navigator.userAgent)) {
      $('.cover').removeClass('hide');
      $('.wechat-tips').removeClass('hide');
      $('.navbar-fixed-top').css('z-index', 0);
    }

    var text = $(that).html();
    that.html(that.data('loading-text'));

    setTimeout(function () {
      that.html(text);
      $('.ios-install-issues').removeClass('d-none');
    }, 8000);

    var install_url = that.data('install-url');

    console.log('install url: '+ install_url);
    window.location.href = install_url;
  });

  $('.cover').click(function () {
    $(this).addClass('hide');
    $('.wechat-tips').addClass('hide');
    $('.navbar-fixed-top').css('z-index', 1030);
  });

  $('.ios-install-issues a').click(function () {
    $('#install-issues').modal('toggle');
  });
});