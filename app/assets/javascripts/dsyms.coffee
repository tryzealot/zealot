# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "turbolinks:load", ->
  $('.destroy_dsym').click ->
    dsym_id = $(this).data('id')
    that = $("#dsym-info-" + dsym_id)

    href = that.find('.dsym-title')
    app_name = href.html()
    version = that.find('.dsym-version').text()

    elm = $('#destory_modal')
    elm.find('.empty-content').html(app_name + " v" + version ).addClass('text-danger')
    elm.find('a').attr('href', "/dsyms/" + dsym_id)
    elm.modal('toggle')