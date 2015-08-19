# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

download = ->
  wechat = /MicroMessenger/i

  if wechat.test(navigator.userAgent)
    $('.cover').removeClass('hide')
    $('.wechat-tips').removeClass('hide')
    $('.navbar-fixed-top').css('z-index', 0)

  slug = $('#download_it').data('slug')
  release_id = $('#download_it').data('release-id')
  device_type = $('.app-type').html()


  installAPI = "https://" + location.hostname + (if location.port then ':' + location.port else '') + "/api/app/" + slug + "/" + release_id + "/install/"

  if device_type == 'Android'
    url = installAPI
  else if device_type == 'iOS' || device_type == 'iPhone' || device_type == 'iPad'
    url = "itms-services://?action=download-manifest&url=" + installAPI

  console.log 'device:', device_type
  console.log 'url:', url
  window.location.href = url


hideCover = ->
  $('.cover').addClass('hide')
  $('.wechat-tips').addClass('hide')
  $('.navbar-fixed-top').css('z-index', 1030)

# bind function
window.download = download
window.hideCover = hideCover

ready = ->
  Dropzone.options.dropzone =
    paramName: "file"
    maxFilesize: 100
    maxFiles: 1
    init: ->
      console.log 'initial'
    accept: (file, done) ->
      console.log "uploaded"
      ext = file.name.split('.').pop().toLowerCase()
      if $.inArray(ext, ['ipa', 'apk']) == -1 then done("请上传 ipa 或 apk 文件") else done()
    success: (file, data) ->
      url = HOST + "releases/" + data.id + "/edit"
      console.log 'success, redirect to %s', url

$(document).ready(ready)
$(document).on('page:load', ready)
