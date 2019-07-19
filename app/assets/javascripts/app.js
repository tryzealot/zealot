function download() {
  var wechat_regex = /MicroMessenger/i;
  var that = $('#download_it');
  if (wechat_regex.test(navigator.userAgent)) {
    $('.cover').removeClass('hide');
    $('.wechat-tips').removeClass('hide');
    $('.navbar-fixed-top').css('z-index', 0);
  }

  that.button('loading');

  setTimeout(function () {
    that.button('reset');
  }, 8000)

  // var slug = that.data('slug');
  // var release_version = that.data('release-version');
  var install_url = that.data('install-url');

  console.log('install url: '+ install_url);
  window.location.href = install_url;
}

function build() {
  var button = $('#build_it');
  button.button('loading');

  var app_job = button.data('job');
  var url = HOST + "api/v2/jenkins/projects/" + app_job + "/build";
  console.log('build url: ', url);

  $.ajax({
    url: url,
    type: 'get',
    dataType: 'json',
    success: function (data) {
      console.log(data)
      if (data.code == 201 || data.code == 200) {
        var url = data.url + 'console';
        message = '请求成功！访问这里查看详情：<a href="' + url + '">' + url + '</a>';
      } else {
        message = '错误：' + data.message;
      }

      if (data.code == 201) {
        sleep(8000);
      }

      $('#jekins_buld_alert').removeClass('hidden').html(message);
    },
    error: function (xhr, ajaxOptions, thrownError) {
      button.button('reset');
      //  $('#cache-info').data('key', xhr.responseJSON.cache).removeClass('hide')
      //  $("#result")
      //      .html('请求失败！接口返回：' + xhr.responseJSON.message)
      //      .addClass("alert alert-danger")
      //      .show()
    },
    complete: function () {
      button.button('reset');
    }
  });
}

function hideCover() {
  $('.cover').addClass('hide');
  $('.wechat-tips').addClass('hide');
  $('.navbar-fixed-top').css('z-index', 1030);
}

function sleep(ms) {
  var start = new Date().getTime();
  while (new Date().getTime() - start < ms)
    continue
}

// # bind function
// window.download = download();
// window.build = build();
// window.hideCover = hideCover();

  // ready = ->
  //   Dropzone.options.dropzone =
  //     paramName: "file"
  //     maxFilesize: 100
  //     maxFiles: 1
  //     init: ->
  //       console.log 'initial'
  //     accept: (file, done) ->
  //       console.log "uploaded"
  //       ext = file.name.split('.').pop().toLowerCase()
  //       if $.inArray(ext, ['ipa', 'apk']) == -1 then done("请上传 ipa 或 apk 文件") else done()
  //     success: (file, data) ->
  //       url = HOST + "releases/" + data.id + "/edit"
  //       console.log 'success, redirect to %s', url

function badget_scm_info() {
  var value
  $('.git-branch').click(function () {
    value = $(this).html();
  })

  var branch = $(this).data('branch')
  var commit = $(this).data('commit')
  if (value == branch)
    $(this).html(commit)
  else
    $(this).html(branch)
}

$(document).on("turbolinks:load", function () {
  //  if window.location.pathname == '/apps/upload'
  //  ready
  //  else
  //  document.addEventListener('turbolinks:load', badget_scm_info)

  $('.release-changelogs-toggle').click(function () {
    var release_id = $(this).data('id');
    $('.release-' + release_id + '-changelog').toggleClass('hide');
  })
});

