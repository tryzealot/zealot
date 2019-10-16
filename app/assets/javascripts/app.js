
function compare_version(v1, v2) {
  if (typeof v1 !== 'string') return false;
  if (typeof v2 !== 'string') return false;
  v1 = v1.split('.');
  v2 = v2.split('.');
  const k = Math.min(v1.length, v2.length);
  for (let i = 0; i < k; ++ i) {
      v1[i] = parseInt(v1[i], 10);
      v2[i] = parseInt(v2[i], 10);
      if (v1[i] > v2[i]) return 1;
      if (v1[i] < v2[i]) return -1;
  }
  return v1.length == v2.length ? 0: (v1.length < v2.length ? -1 : 1);
}

function set_cookie(name, value, days) {
  var expires = "";
  if (days) {
      var date = new Date();
      date.setTime(date.getTime() + (days*24*60*60*1000));
      expires = "; expires=" + date.toUTCString();
  }
  document.cookie = name + "=" + (value || "")  + expires + "; path=/";
}

function get_cookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for(var i=0;i < ca.length;i++) {
      var c = ca[i];
      while (c.charAt(0)==' ') c = c.substring(1,c.length);
      if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
  }
  return null;
}

function show_new_version() {
  url = $('#zealot_latest_version_url').html();
  version = get_cookie('zealot_latest_version_full');

  $('#latest_version').html('<a href="' + url + '" target="_blank" title="检查新版本">' + version + '</a>');
}

function check_new_version() {
  var current_version = $('#current_version').html();
  var stored_version = get_cookie('zealot_latest_version');
  if (stored_version == null) {
    $.ajax({
      url: 'https://api.github.com/repos/icyleaf/zealot/releases/latest?client_id=44389300f0e99215e109&client_secret=6e70de02dc2fe43a7737b2dff96e919226c0a26a',
      headers: {
        accept: 'application/vnd.github.v3+json',
      }
    }).done(function (response) {
      latest_version = response['tag_name'].replace('v', '');
      if (compare_version(latest_version, current_version) > 0) {
        set_cookie('zealot_latest_version', latest_version, 1);
        set_cookie('zealot_latest_version_full', response['name'], 1);
        set_cookie('zealot_latest_version_url', response['html_url'], 1);

        show_new_version();
      }
    });
  } else {
    if (compare_version(stored_version, current_version) > 0) {
      show_new_version();
    }
  }
}

$('#latest_version').ready(function () {
  check_new_version();
});


// function sleep(ms) {
//   var start = new Date().getTime();
//   while (new Date().getTime() - start < ms)
//     continue
// }

// function download() {
//   var wechat_regex = /MicroMessenger/i;
//   var that = $('#download_it');
//   if (wechat_regex.test(navigator.userAgent)) {
//     $('.cover').removeClass('hide');
//     $('.wechat-tips').removeClass('hide');
//     $('.navbar-fixed-top').css('z-index', 0);
//   }

//   that.button('loading');

//   setTimeout(function () {
//     that.button('reset');
//   }, 8000)

//   // var slug = that.data('slug');
//   // var release_version = that.data('release-version');
//   var install_url = that.data('install-url');

//   console.log('install url: '+ install_url);
//   window.location.href = install_url;
// }

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

// function hideCover() {
//   $('.cover').addClass('hide');
//   $('.wechat-tips').addClass('hide');
//   $('.navbar-fixed-top').css('z-index', 1030);
// }

// function getAverageRGB(imgEl) {
//   var blockSize = 5, // only visit every 5 pixels
//       defaultRGB = {r:0,g:0,b:0}, // for non-supporting envs
//       canvas = document.createElement('canvas'),
//       context = canvas.getContext && canvas.getContext('2d'),
//       data, width, height,
//       i = -4,
//       length,
//       rgb = {r:0,g:0,b:0},
//       count = 0;

//   if (!context) {
//       return defaultRGB;
//   }

//   height = canvas.height = imgEl.naturalHeight || imgEl.offsetHeight || imgEl.height;
//   width = canvas.width = imgEl.naturalWidth || imgEl.offsetWidth || imgEl.width;

//   context.drawImage(imgEl, 0, 0);

//   try {
//       data = context.getImageData(0, 0, width, height);
//   } catch(e) {
//       /* security error, img on diff domain */alert('x');
//       return defaultRGB;
//   }

//   length = data.data.length;

//   while ( (i += blockSize * 4) < length ) {
//       ++count;
//       rgb.r += data.data[i];
//       rgb.g += data.data[i+1];
//       rgb.b += data.data[i+2];
//   }

//   // ~~ used to floor values
//   rgb.r = ~~(rgb.r/count);
//   rgb.g = ~~(rgb.g/count);
//   rgb.b = ~~(rgb.b/count);

//   return rgb;
// }

// // # bind function
// // window.download = download();
// // window.build = build();
// // window.hideCover = hideCover();

//   // ready = ->
//   //   Dropzone.options.dropzone =
//   //     paramName: "file"
//   //     maxFilesize: 100
//   //     maxFiles: 1
//   //     init: ->
//   //       console.log 'initial'
//   //     accept: (file, done) ->
//   //       console.log "uploaded"
//   //       ext = file.name.split('.').pop().toLowerCase()
//   //       if $.inArray(ext, ['ipa', 'apk']) == -1 then done("请上传 ipa 或 apk 文件") else done()
//   //     success: (file, data) ->
//   //       url = HOST + "releases/" + data.id + "/edit"
//   //       console.log 'success, redirect to %s', url

// function badget_scm_info() {
//   var value
//   $('.git-branch').click(function () {
//     value = $(this).html();
//   })

//   var branch = $(this).data('branch')
//   var commit = $(this).data('commit')
//   if (value == branch)
//     $(this).html(commit)
//   else
//     $(this).html(branch)
// }

// $(document).on("turbolinks:load", function () {
//   //  if window.location.pathname == '/apps/upload'
//   //  ready
//   //  else
//   //  document.addEventListener('turbolinks:load', badget_scm_info)

//   $('.release-changelogs-toggle').click(function () {
//     var release_id = $(this).data('id');
//     $('.release-' + release_id + '-changelog').toggleClass('hide');
//   })
// });


// // $(document).ready(function () {
// //   $('#apps-list .app').each(function (index) {
// //     var icon = $(this).find('.app-icon').first();
// //     console.log(icon);
// //     var rgb = getAverageRGB(icon[0]);
// //     console.log(rgb);
// //     $(this).find('.info-box').css('backgroundColor', 'rgb(' + rgb.r + ',' + rgb.g + ',' + rgb.b + ')');
// //   })
// // });
