# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

words = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
  'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
]

number2word = (i) ->
  words[i]

drag_default_map = (element)->
  location_array = $('#location').val().split(",")
  console.log location_array
  lat = parseFloat($.trim(location_array[0]))
  lng = parseFloat($.trim(location_array[1]))
  zoom = 14

  geocoder = new google.maps.Geocoder()
  myLatlng = new google.maps.LatLng(lat, lng)
  myOptions =
    zoom: zoom,
    center: myLatlng,
    # disableDefaultUI: true,
    mapTypeId: google.maps.MapTypeId.ROADMAP

  map = new google.maps.Map(document.getElementById(element), myOptions)
  marker = new google.maps.Marker
    position: myLatlng
    map: map

  google.maps.event.addListener(map, "center_changed", ->
    document.getElementById("location").value = map.getCenter().lat() + "," + map.getCenter().lng()
    marker.setPosition(map.getCenter())
  )

output_daytours = (data) ->
  title = $.trim($('select#route option:checked').text())
  $('#daytour').removeClass('hidden')
  $('#daytour h2').html(title)
  $('#daytour table tbody').empty()

  location_array = $('#location').val().split(",")
  lat = parseFloat($.trim(location_array[0]))
  lng = parseFloat($.trim(location_array[1]))
  locations = [
    {
      lat: lat,
      lon: lng,
      title: '0 - 用户所在地',
      html: '<h4>用户所在地</h4>',
      icon: 'http://www.google.com/mapfiles/dd-start.png'
    }
  ]

  icon_no = 0
  $(data).each((i, item) ->
    row_class = ''
    row_no = ''
    row_select = ''
    row_body = ''
    row_action = ''

    if item.type == 'poi'
      row_class = 'poi-row'
      if item.poi_id > 0
        iconWord = number2word(icon_no++)
        row_no = iconWord

        locations.push({
          lat: item.lng,
          lon: item.lat,
          title: iconWord + ' - ' + item.poiname,
          icon: 'http://maps.google.com/mapfiles/marker' + iconWord + '.png',
          html: [
            '<h4><a href="http://place.qyer.com/poi/' + item.poi_id + '" target="_blank">' + item.poiname + '</a></h4>',
            '<p>分类：' + item.catename,
            '</p><p>建议时间：' + item.arrival_time + '(' + item.duration + '分)',
            '</p><p>坐标：' + item.lat + ',' + item.lng + '</p>'
          ].join('')
        })
        row_select = '<input class="route-select" type="checkbox" data-id="' + item.poi_id +
          '" data-lng="' + item.geo[1] + '" data-lat="' + item.geo[0] + '" ' + (if ! item.selected then ' disabled="disabled"' else '') + ' />'
        row_body = item.arrival_time + ' / ' + item.catename + ' / ' +
          '<a href="http://place.qyer.com/poi/' + item.poi_id + '" target="_blank">' + item.poiname + '</a> / 建议游玩：' + item.duration + '分 / 距离' +
          item.distance + '公里<br />坐标：' + item.lat + ',' + item.lng
        row_action = '<button class="remove-poi btn btn-default">不感兴趣</button>'
      else
        row_body = '建议 ' + item.arrival_time + ' 预留出来进行 [' + item.catename + ']'
    else
      row_class = 'traffic-row warning'
      row_body = '[' + item.mode + '] 花费时间 ' + item.traffic_time + ' 分'
      if item.segments.length > 0
        row_body += '<ol>'
        for way in item.segments
          row_body += '<li>[' + way.kind + '] ' + way.sName + ' - ' + way.tName +
            ' / 距离 ' + way.distance + ' 千米 / 花费 ' + way.duration + ' 分</li>'
        row_body += '</ol>'


    row_html = '<tr class="' + row_class + '">' +
      '<td>' + row_select + '</td>' +
      '<td>' + row_no + '</td>' +
      '<td>' + row_body + '</td>' +
      '<td>' + row_action + '</td>' +
    '</tr>'

    $('#daytour table tbody').append(row_html)
  )

  $('#map-route').empty()
  new Maplace({
    locations: locations,
    map_div: '#map-route',
    controls_on_map: true,
    controls_type: 'list',
    view_all_text: '线路总览',
    type: 'polyline',
  }).Load();

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
  lat = parseFloat($.trim(location_array[0]))
  lng = parseFloat($.trim(location_array[1]))
  distance = 100
  random = Math.random()
  around_distance = parseFloat((random / distance).toFixed(8))

  (lat + around_distance).toFixed(8) + "," + (lng + around_distance).toFixed(8)

baidu_geo_foramt = (location) ->
  location_array = location.split(",")
  lat = parseFloat($.trim(location_array[0]))
  lng = parseFloat($.trim(location_array[1]))

  lat + "," + lng

###############################################################

$(document).ready ->

  if window.location.pathname == '/demo/plans/index'
    # 显示默认数据的地图
    drag_default_map('gmap')

    # 激活日期时间拾取器
    $("#date").datetimepicker({format: 'yyyy-mm-dd hh:ii', language: 'zh-CN'});

    $('#location').bind('change paste keypress', ->
      # console.log $(this).val()
      drag_default_map('gmap')
    )

  # 查找用户信息（设备）
  timer = 0
  $('#uid').keyup ->
    input = $(this)
    clearTimeout(timer);
    timer = setTimeout( ->
      $.ajax
        url: HOST + "api/user/" + $(input).val() + ".json",
        type: 'get'
        dataType: 'json'
        beforeSend: ->
          $(input).prop('disabled', 'true')
          $('#device_id').val('设备搜查中...')
          $('#recommend-daytour').prop('disabled', 'true')
        success: (data) ->
          $('#device_id').val(data.device_id)
          $(input).val(data.id)
          if data.device_id
            $('#recommend-daytour').removeProp('disabled')
        error: (xhr, ajaxOptions, thrownError) ->
          $('#device_id').val(xhr.responseTEXT)
        complete: ->
          $(input).removeProp('disabled')
    , 1000)

  # 请求每日推荐行程
  $('#recommend-daytour').click ->
    $("#result").hide()
    $('#cache-info').addClass('hide')

    button = $(this)
    value = $(button).val()
    params =
      uid: $('#uid').val()
      device_id: $('#device_id').val()
      date: $('#date').val()
      location: $('#location').val()
      route: $('#route').val()

    $.ajax
      url: HOST + "api/demo/dayroutes/show.json",
      data: params
      type: 'get'
      dataType: 'json'
      beforeSend: ->
        $(button).val('推荐组合中...').prop('disabled', 'true')
      success: (data) ->
        console.log data
        output_daytours(data.entry)
        $(button).val(value)
        $('#cache-info').data('key', data.cache).removeClass('hide')
      error: (xhr, ajaxOptions, thrownError) ->
        $(button).val('接口错误，再来一次！')
        $('#cache-info').data('key', xhr.responseJSON.cache).removeClass('hide')
        $("#result")
            .html('请求失败！接口返回：' + xhr.responseJSON.message)
            .addClass("alert alert-danger")
            .show()
      complete: ->
        $(button).removeProp('disabled')

  # 忽略单个景点，计算上下俩个景点之间的距离
  $('#daytour table').on('click', '.remove-poi', ->
    $("#result").hide()
    row_index = $(this).parent().parent().index() + 1
    last_index = $('#route-table tr:last').index()
    console.log "current row: %d, last: %d", row_index, last_index

    if row_index == last_index
      $('#route-table tr:eq(' + row_index + ')').remove()
      $('#route-table tr:eq(' + (row_index - 1) + ')').remove()

    else if row_index > 1
      source_element = $('#route-table tr:eq(' + (row_index - 2) + ') input.route-select')
      target_element = $('#route-table tr:eq(' + (row_index + 2) + ') input.route-select')

      params =
        source_id: $(source_element).data('id')
        source_lat: $(source_element).data('lat')
        source_lng: $(source_element).data('lng')
        target_id: $(target_element).data('id')
        target_lat: $(target_element).data('lat')
        target_lng: $(target_element).data('lng')

      traffic_element = $('#route-table tr:eq(' + (row_index - 1) + ')')
      traffic_html = $(traffic_element).html()

      $.ajax
        url: HOST + "api/demo/dayroutes/traffic.json",
        data: params
        type: 'get'
        dataType: 'json'
        beforeSend: ->
          $(traffic_element).html('<td colspan="5" style="text-align:center;color:red">路程计算中</td>')
        success: (data) ->
          console.debug data

          $(traffic_element).html('<td></td><td></td>' +
            '<td>traffic</td>' +
            '<td>[' + data.mode + '] 花费时间 ' + data.traffic_time + '分</td>' +
            '<td></td>')

          $('#route-table tr:eq(' + row_index + ')').remove()
          $('#route-table tr:eq(' + row_index + ')').remove()

          iconWord = 0
          $('#route-table tbody tr').each((i, element) ->
            iconWord = number2word(iconWord++)
            $(element).find('td:eq(1)').html(iconWord)
          )

        error: (xhr, ajaxOptions, thrownError) ->
          $(traffic_element).html(traffic_html)
          $("#result")
            .html('请求失败！接口返回：' + xhr.responseJSON.message)
            .addClass("alert alert-danger")
            .show()
    else
      $('#route-table tr:eq(' + row_index + ')').remove()
      $('#route-table tr:eq(' + row_index + ')').remove()
  )

  # 清除路线推荐的缓存
  $('#clear-cache').click ->
    button = $(this)
    params =
      uid: $('#uid').val()
      device_id: $('#device_id').val()
      date: $('#date').val()
      location: $('#location').val()
      route: $('#route').val()
    $.ajax
      url: HOST + "api/demo/dayroutes/clear_cache.json",
      data: params
      type: 'delete'
      dataType: 'json'
      beforeSend: ->
        $(button).val('清理...').prop('disabled', 'true')
      success: (data) ->
        console.log data
      complete: ->
        $(button).val('再次清理').removeProp('disabled')

  # 新增随机用户时间和坐标
  $('#new-row').click ->
    last_row = $('#locations-table tr:last')
    if last_row.data('row')?
      row_no = $(last_row).data('row')
      time = $(last_row).find('input[name=time]').val()
      location = $(last_row).find('input[name=location]').val()
    else
      row_no = 0
      time = '07:00'
      location = '22.3245866064,114.173473119'

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

  # 上报用户的时间和坐标
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
      url: HOST + "api/demo/dayroutes/upload_location.json",
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

  # 每日推荐行程的全选
  $('.select-all').click ->
    $('.route-select:checkbox').each((i, element) ->
      check_status = element.checked
      console.log element
      console.log check_status
      if check_status
        $(element).removeProp('checked')
        $(this).html('反选')
      else
        $(element).prop('checked', 'checked')
        $(this).html('全选')
    )

  # 查看缓存详情
  $('#cache-info').click ->
    key = $(this).data('key')
    url = HOST + 'api/demo/dayroutes/cache.json?key=' + key
    window.open(url, '_blank')

  # 重新推荐每日行程（发送景点删除）
  $('.update-route').click ->
    button = $(this)
    value = $(button).val()
    pois = []
    $('.route-select:checkbox:checked').each((i, element) ->
      pois.push $(element).data('id')
    )

    $("#result").hide()
    if pois.length > 0
      params =
        device_id: $('#device_id').val()
        date: $('#date').val()
        location: $('#location').val()
        dislike_poiids: pois.join(',')
        uid: $('#uid').val()
        route: $('#route').val()

      $.ajax
        url: HOST + "api/demo/dayroutes/update.json",
        data: params
        type: 'get'
        dataType: 'json'
        beforeSend: ->
          $(button).html('重新组合中...').prop('disabled', 'true')
        success: (data) ->
          console.debug data
          output_daytours(data.entry)

          $(button).html('重新推荐')
          $("#result")
            .html('路线已忽略选中的景点并重新推荐')
            .addClass("alert alert-success")
            .show()

        error: (xhr, ajaxOptions, thrownError) ->
          console.log xhr
          $(button).html('重新推荐')
          $('#cache-info').data('key', xhr.responseJSON.cache).removeClass('hide')
          $("#result")
            .html('请求失败！接口返回：' + xhr.responseJSON.message)
            .addClass("alert alert-danger")
            .show()
        complete: ->
          $(button).removeProp('disabled')
    else
      $("#result")
        .html('你还没有选择景点')
        .addClass("alert alert-warning")
        .show()
