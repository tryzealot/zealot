import compareVersion from 'compare-versions';
const newVesionUrl = 'https://api.github.com/repos/tryzealot/zealot/releases/latest';

function insert_link(elm, title, link) {
  elm.html(
    '<a target="_blank" href="' + link + '">' +
    '<i class="fas fa-rainbow"></i>' + title + '</a>');
}

function check_new_version() {
  var elm = $('#new-version');
  if (!elm.length) { return; }

  var current_version = $('#current-version').html();
  if (current_version == 'development') {
    insert_link(elm, '发现新版本 (始终显示)', 'https://github.com/tryzealot/zealot');
    return;
  }

  fetch(newVesionUrl, {
    method: 'GET',
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'Accept': 'application/vnd.github.v3+json'
    }
  }).then((response) => response.json())
    .then(json => {
      var latest_version = json.tag_name;
      if (compareVersion(latest_version, current_version) <= 0) { return; }

      var release_link = json.html_url;
      insert_link(elm, '发现新版本 ' + latest_version, release_link);
  });
}

$(document).on('turbolinks:load', () => {
  check_new_version();
});