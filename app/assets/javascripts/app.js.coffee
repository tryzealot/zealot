# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

download = ->
  slug = $('#download_it').data('slug')
  installAPI = "https://" + location.hostname + (if location.port then ':' + location.port else '') + "/api/app/" + slug + "/install"
  url = "itms-services://?action=download-manifest&url=" + installAPI
  console.log 'url:', url
  window.location.href = url


# bind function
window.download = download
