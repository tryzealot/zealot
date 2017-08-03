# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

download = ->
  wechat = /MicroMessenger/i
  that = $('#download_it')

  if wechat.test(navigator.userAgent)
    $('.cover').removeClass('hide')
    $('.wechat-tips').removeClass('hide')
    $('.navbar-fixed-top').css('z-index', 0)

  that.button('loading');

  setTimeout ->
    that.button('reset')
  , 8000

  slug = that.data('slug')
  release_version = that.data('release-version')
  install_url = that.data('install-url')

  console.log 'url: ', install_url
  window.location.href = install_url

build = ->
  button = $('#build_it')
  button.button('loading')

  app_job = button.data('job')
  url = HOST + "api/v2/jenkins/projects/" + app_job + "/build"
  console.log 'build url: ', url

  $.ajax
    url: url,
    type: 'get'
    dataType: 'json'
    success: (data) ->
      console.log data
      if data.code == 201 || data.code == 200
        url = data.url + 'console'
        message = '请求成功！访问这里查看详情：<a href="' + url + '">' + url + '</a>'
      else
        message = '错误：' + data.message

      sleep 8000 if data.code == 201

      $('#jekins_buld_alert').removeClass('hidden').html(message)

    error: (xhr, ajaxOptions, thrownError) ->
      button.button('reset')
      # $('#cache-info').data('key', xhr.responseJSON.cache).removeClass('hide')
      # $("#result")
      #     .html('请求失败！接口返回：' + xhr.responseJSON.message)
      #     .addClass("alert alert-danger")
      #     .show()
    complete: ->
      button.button('reset')

hideCover  = ->
  $('.cover').addClass('hide')
  $('.wechat-tips').addClass('hide')
  $('.navbar-fixed-top').css('z-index', 1030)

sleep = (ms) ->
  start = new Date().getTime()
  continue while new Date().getTime() - start < ms

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

badget_scm_info = ->
  $('.git-branch').click ->
    value = $(this).html()
    branch = $(this).data('branch')
    commit = $(this).data('commit')
    if value == branch
      $(this).html(commit)
    else
      $(this).html(branch)

$(document).on "turbolinks:load", ->
  # if window.location.pathname == '/apps/upload'
  #   ready
  # else
  #   document.addEventListener('turbolinks:load', badget_scm_info)


    $('.release-changelogs-toggle').click ->
      release_id = $(this).data('id')
      $('.release-' + release_id + '-changelog').toggleClass('hide')
