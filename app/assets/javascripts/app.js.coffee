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
  else if device_type.toLowerCase() == 'ios' || device_type.toLowerCase() == 'iphone' || device_type.toLowerCase() == 'ipad'
    url = "itms-services://?action=download-manifest&url=" + installAPI

  console.log 'device:', device_type
  console.log 'url:', url
  window.location.href = url

build = ->
  button = $('#build_it')
  app_job = button.data('job')
  $.ajax
    url: HOST + "api/jenkins/" + app_job + "/build",
    type: 'get'
    dataType: 'json'
    beforeSend: ->
      $(button).html('构建新版本中...').prop('disabled', 'true')
    success: (data) ->
      console.log data
      if data.status == '201'
        console.log 'ddddd'
        url = data.project.lastBuild.url + 'console'
        $('#jekins_buld_alert').removeClass('hidden').html('请求成功！访问这里查看详情：<a href="' + url + '">' + url + '</a>')

    error: (xhr, ajaxOptions, thrownError) ->
      $(button).html('接口错误，再来一次！')
      # $('#cache-info').data('key', xhr.responseJSON.cache).removeClass('hide')
      # $("#result")
      #     .html('请求失败！接口返回：' + xhr.responseJSON.message)
      #     .addClass("alert alert-danger")
      #     .show()
    complete: ->
      $(button).html('构建新版本').removeProp('disabled')

hideCover = ->
  $('.cover').addClass('hide')
  $('.wechat-tips').addClass('hide')
  $('.navbar-fixed-top').css('z-index', 1030)


# bind function
window.download = download
window.build = build
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


$(document).ready ->
  if window.location.pathname == '/apps/upload'
    ready()
  else
    $('.git-branch').click ->
      value = $(this).html()
      branch = $(this).data('branch')
      commit = $(this).data('commit')
      if value == branch
        $(this).html(commit)
      else
        $(this).html(branch)

    $('.cover').removeClass('hide');
    $('.wechat-tips').removeClass('hide');
    $('.navbar-fixed-top').css('z-index', 0);

