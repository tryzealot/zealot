# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

add_zero = (num) ->
  if (num < 10)
    num = "0" + num
  num

follow_time = (time) ->
  date = $('#date').val()
  timestamp = Date.parse(date + " " + time)
  random_minutes = Math.round(Math.random() * 100)

  date_object = new Date(timestamp + random_minutes * 1000 * 60)
  date_object.getHours() + ":" + add_zero(date_object.getMinutes())

nearby_geo = (location) ->
  location_array = location.split(",")
  lon = parseFloat($.trim(location_array[0]))
  lat = parseFloat($.trim(location_array[1]))
  distance = 100
  random = Math.random()
  around_distance = parseFloat((random / distance).toFixed(8))

  (lon + around_distance).toFixed(8) + "," + (lat + around_distance).toFixed(8)

baidu_geo_foramt = (location) ->
  location_array = location.split(",")
  lon = parseFloat($.trim(location_array[0]))
  lat = parseFloat($.trim(location_array[1]))

  lat + "," + lon

$(document).ready ->
  $('#new-row').click ->
    last_row = $('#locations-table tr:last')
    if last_row.data('row')?
      row_no = $(last_row).data('row')
      time = $(last_row).find('input[name=time]').val()
      location = $(last_row).find('input[name=location]').val()
    else
      row_no = 0
      time = '08:00'
      location = '114.173473119,22.3245866064'

    next_row = row_no + 1
    next_time = follow_time(time)
    next_location = nearby_geo(location)

    baidu_url = 'http://api.map.baidu.com/geocoder/v2/?location=' + baidu_geo_foramt(next_location) + '&ak=4E23365d590adb14920d402a12929e2d&output=json'

    $.ajax
      url: baidu_url
      type: 'get'
      dataType: 'jsonp'
      success: (data) ->
        console.log data
        address = if data.status == 0 then data.result.formatted_address else ""
        console.log address
        $('#locations-table tr:last').after('<tr id="row-' + next_row + '" data-row="' + next_row + '">' +
          '<td><input class="record-time" name="time" value="' + next_time + '"/></td>' +
          '<td><input class="record-location" name="location" value="' + next_location + '" />' +
          '<a href="http://api.map.baidu.com/geocoder/v2/?location=' + baidu_geo_foramt(next_location) + '&ak=4E23365d590adb14920d402a12929e2d&output=json" target="_blank">坐标查询</a>' +
          '<br /><span class="record-address">' + address + '</span></td>' +
          '<td><button class="btn btn-info store-record" data-row="' + next_row + '">记录坐标</button></td>' +
        '</tr>')

  $('#locations-table').on('click', '.store-record', ->
    button = $(this)
    row_no = $(this).data('row')
    row = $('#row-' + row_no)
    params =
      device_id: $('#device_id').val()
      date: $('#date').val()
      address: $(row).find('span.record-address').html()
      time: $(row).find('input[name=time]').val()
      location: $(row).find('input[name=location]').val()

    $.ajax
      url: HOST + "demo/plans/store_record",
      data: params
      type: 'post'
      dataType: 'json'
      beforeSend: ->
        $(button).html('上报中...').attr('disabled', 'true')
      complete: (data) ->
        $(button).html('已记录')
        $(button).attr('disabled', 'true')
        $(row).find('input[name=time]').attr('disabled', 'true')
        $(row).find('input[name=location]').attr('disabled', 'true')
  )

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
