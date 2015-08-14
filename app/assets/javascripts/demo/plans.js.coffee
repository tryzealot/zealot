# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('.select-all').click ->
    select_button = $(this)
    checkbox = $(this).data('tab') + '-select'
    $('.' + checkbox).each((i, element) ->
      check_status = if $(element).attr('checked') then true else false
      console.log element
      console.log check_status

      $(element).attr('checked', !check_status)
      $(select_button).html(if check_status then '全选' else '反选')
    )

  $('.delete-route').click ->
    button = $(this)
    checkbox = $(this).data('tab') + '-select:checked'

    pois = []
    $('.' + checkbox).each((i, element) ->
      pois.push $(element).data('id')
    )

    if pois.length > 0
      alert '你选择的景点有' + pois
    else
      alert '你没有选择要删除的景点'
