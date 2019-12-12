
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
      url: 'https://api.github.com/repos/getzealot/zealot/releases/latest?client_id=44389300f0e99215e109&client_secret=6e70de02dc2fe43a7737b2dff96e919226c0a26a',
      headers: {
        accept: 'application/vnd.github.v3+json',
      }
    }).done(function (response) {
      latest_version = response['tag_name'].replace('v', '');
      console.info(latest_version);

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

$(document).on('turbolinks:load', function () {
  $('#latest_version').ready(function () {
    if (window.location.pathname == '/admin/system_info') {
      check_new_version();
    }
  });
});