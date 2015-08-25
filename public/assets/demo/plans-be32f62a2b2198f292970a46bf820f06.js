(function() {
  var add_zero, baidu_geo_foramt, drag_default_map, follow_time, nearby_geo, output_daytours;

  drag_default_map = function(element) {
    var geocoder, lat, lng, location_array, map, marker, myLatlng, myOptions, zoom;
    location_array = $('#location').val().split(",");
    lng = parseFloat($.trim(location_array[0]));
    lat = parseFloat($.trim(location_array[1]));
    zoom = 14;
    geocoder = new google.maps.Geocoder();
    myLatlng = new google.maps.LatLng(lat, lng);
    myOptions = {
      zoom: zoom,
      center: myLatlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById(element), myOptions);
    marker = new google.maps.Marker({
      position: myLatlng,
      map: map
    });
    return google.maps.event.addListener(map, "center_changed", function() {
      document.getElementById("location").value = map.getCenter().lng() + "," + map.getCenter().lat();
      return marker.setPosition(map.getCenter());
    });
  };

  output_daytours = function(data) {
    var lat, lng, location_array, locations, title, words;
    title = $.trim($('select#route option:checked').text());
    $('#daytour').removeClass('hidden');
    $('#daytour h2').html(title);
    $('#daytour table tbody').empty();
    location_array = $('#location').val().split(",");
    lng = parseFloat($.trim(location_array[0]));
    lat = parseFloat($.trim(location_array[1]));
    locations = [
      {
        lat: lat,
        lon: lng,
        title: '我',
        html: '<h3>我</h3>',
        type: 'circle',
        circle_options: {
          radius: 200
        }
      }
    ];
    words = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
    $(data).each(function(i, item) {
      var iconWord, row_action, row_body, row_class, row_html, row_select;
      row_class = '';
      row_select = '';
      row_body = '';
      row_action = '';
      if (item.type === 'poi') {
        if (i === 0) {
          iconWord = words[i];
        } else {
          iconWord = words[i / 2];
        }
        locations.push({
          lat: item.lng,
          lon: item.lat,
          title: item.poiname,
          icon: 'http://maps.google.com/mapfiles/marker' + iconWord + '.png',
          html: '<h3>' + item.poiname + '</h3>'
        });
        row_class = 'poi-row';
        row_select = '<input class="route-select" type="checkbox" data-id="' + item.poi_id + '" data-lng="' + item.geo[1] + '" data-lat="' + item.geo[0] + '" ' + (!item.selected ? ' disabled="disabled"' : '') + ' />';
        row_body = item.arrival_time + ' / ' + item.catename + ' / ' + '<a href="http://place.qyer.com/poi/' + item.poi_id + '" target="_blank">' + item.poiname + '</a> / 建议游玩：' + item.duration + '分 / 距离' + item.distance + '公里';
        row_action = '<button class="remove-poi btn btn-default">不感兴趣 ' + iconWord + '</button>';
      } else {
        row_class = 'traffic-row warning';
        row_body = '[' + item.mode + '] 花费时间 ' + item.traffic_time + ' 分';
      }
      row_html = '<tr class="' + row_class + '">' + '<td>' + row_select + '</td>' + '<td>' + (i + 1) + '</td>' + '<td>' + item.type + '</td>' + '<td>' + row_body + '</td>' + '<td>' + row_action + '</td>' + '</tr>';
      return $('#daytour table tbody').append(row_html);
    });
    return new Maplace({
      locations: locations,
      map_div: '#map-route',
      controls_on_map: true,
      controls_type: 'list',
      view_all_text: '路线全揽',
      type: 'polyline'
    }).Load();
  };

  add_zero = function(num) {
    if (num < 10) {
      num = "0" + num;
    }
    return num;
  };

  follow_time = function(time) {
    var date, date_object, random_minutes, timestamp;
    date = $('#date').val();
    timestamp = Date.parse(date + " " + time);
    random_minutes = Math.round(Math.random() * 100);
    date_object = new Date(timestamp + random_minutes * 1000 * 60);
    return date_object.getHours() + ":" + add_zero(date_object.getMinutes());
  };

  nearby_geo = function(location) {
    var around_distance, distance, lat, lng, location_array, random;
    location_array = location.split(",");
    lng = parseFloat($.trim(location_array[0]));
    lat = parseFloat($.trim(location_array[1]));
    distance = 100;
    random = Math.random();
    around_distance = parseFloat((random / distance).toFixed(8));
    return (lng + around_distance).toFixed(8) + "," + (lat + around_distance).toFixed(8);
  };

  baidu_geo_foramt = function(location) {
    var lat, lng, location_array;
    location_array = location.split(",");
    lng = parseFloat($.trim(location_array[0]));
    lat = parseFloat($.trim(location_array[1]));
    return lat + "," + lng;
  };

  $(document).ready(function() {
    drag_default_map('gmap');
    $("#date").datetimepicker({
      format: 'yyyy-mm-dd hh:ii',
      language: 'zh-CN'
    });
    $('#clear-cache').click(function() {
      var button, params;
      button = $(this);
      params = {
        uid: $('#uid').val(),
        device_id: $('#device_id').val(),
        date: $('#date').val(),
        location: $('#location').val(),
        route: $('#route').val()
      };
      return $.ajax({
        url: HOST + "api/demo/dayroutes/clear_cache.json",
        data: params,
        type: 'delete',
        dataType: 'json',
        beforeSend: function() {
          return $(button).val('清理...').prop('disabled', 'true');
        },
        success: function(data) {
          return console.log(data);
        },
        complete: function() {
          return $(button).val('再次清理').removeProp('disabled');
        }
      });
    });
    $('#recommend-daytour').click(function() {
      var button, params;
      button = $(this);
      params = {
        uid: $('#uid').val(),
        device_id: $('#device_id').val(),
        date: $('#date').val(),
        location: $('#location').val(),
        route: $('#route').val()
      };
      return $.ajax({
        url: HOST + "api/demo/dayroutes/show.json",
        data: params,
        type: 'get',
        dataType: 'json',
        beforeSend: function() {
          return $(button).val('推荐组合中...').prop('disabled', 'true');
        },
        success: function(data) {
          console.log(data);
          output_daytours(data);
          return $(button).val('再给爷推荐一次！');
        },
        error: function() {
          return $(button).val('接口错误，再来一次！');
        },
        complete: function() {
          return $(button).removeProp('disabled');
        }
      });
    });
    $('#new-row').click(function() {
      var baidu_url, last_row, location, next_location, next_row, next_time, row_no, time;
      last_row = $('#locations-table tr:last');
      if (last_row.data('row') != null) {
        row_no = $(last_row).data('row');
        time = $(last_row).find('input[name=time]').val();
        location = $(last_row).find('input[name=location]').val();
      } else {
        row_no = 0;
        time = '08:00';
        location = '114.173473119,22.3245866064';
      }
      next_row = row_no + 1;
      next_time = follow_time(time);
      next_location = nearby_geo(location);
      baidu_url = 'http://api.map.baidu.com/geocoder/v2/?location=' + baidu_geo_foramt(next_location) + '&ak=4E23365d590adb14920d402a12929e2d&output=json';
      return $.ajax({
        url: baidu_url,
        type: 'get',
        dataType: 'jsonp',
        success: function(data) {
          var address;
          console.log(data);
          address = data.status === 0 ? data.result.formatted_address : "";
          console.log(address);
          return $('#locations-table tr:last').after('<tr id="row-' + next_row + '" data-row="' + next_row + '">' + '<td><input class="record-time" name="time" value="' + next_time + '"/></td>' + '<td><input class="record-location" name="location" value="' + next_location + '" />' + '<a href="http://api.map.baidu.com/geocoder/v2/?location=' + baidu_geo_foramt(next_location) + '&ak=4E23365d590adb14920d402a12929e2d&output=json" target="_blank">坐标查询</a>' + '<br /><span class="record-address">' + address + '</span></td>' + '<td><button class="btn btn-info store-record" data-row="' + next_row + '">记录坐标</button></td>' + '</tr>');
        }
      });
    });
    $('#locations-table').on('click', '.store-record', function() {
      var button, params, row, row_no;
      button = $(this);
      row_no = $(this).data('row');
      row = $('#row-' + row_no);
      params = {
        device_id: $('#device_id').val(),
        date: $('#date').val(),
        address: $(row).find('span.record-address').html(),
        time: $(row).find('input[name=time]').val(),
        location: $(row).find('input[name=location]').val()
      };
      return $.ajax({
        url: HOST + "api/demo/dayroutes/upload_location.json",
        data: params,
        type: 'post',
        dataType: 'json',
        beforeSend: function() {
          return $(button).html('上报中...').attr('disabled', 'true');
        },
        complete: function(data) {
          $(button).html('已记录');
          $(button).attr('disabled', 'true');
          $(row).find('input[name=time]').attr('disabled', 'true');
          return $(row).find('input[name=location]').attr('disabled', 'true');
        }
      });
    });
    $('#daytour table').on('click', '.remove-poi', function() {
      var last_index, params, row_index, source_element, target_element, traffic_element, traffic_html;
      $("#result").hide();
      row_index = $(this).parent().parent().index() + 1;
      last_index = $('#route-table tr:last').index();
      console.log("current row: %d, last: %d", row_index, last_index);
      if (row_index === last_index) {
        $('#route-table tr:eq(' + row_index + ')').remove();
        return $('#route-table tr:eq(' + (row_index - 1) + ')').remove();
      } else if (row_index > 1) {
        source_element = $('#route-table tr:eq(' + (row_index - 2) + ') input.route-select');
        target_element = $('#route-table tr:eq(' + (row_index + 2) + ') input.route-select');
        params = {
          source_id: $(source_element).data('id'),
          source_lat: $(source_element).data('lat'),
          source_lng: $(source_element).data('lng'),
          target_id: $(target_element).data('id'),
          target_lat: $(target_element).data('lat'),
          target_lng: $(target_element).data('lng')
        };
        traffic_element = $('#route-table tr:eq(' + (row_index - 1) + ')');
        traffic_html = $(traffic_element).html();
        return $.ajax({
          url: HOST + "api/demo/dayroutes/traffic.json",
          data: params,
          type: 'get',
          dataType: 'json',
          beforeSend: function() {
            return $(traffic_element).html('<td colspan="5" style="text-align:center;color:red">路程计算中</td>');
          },
          success: function(data) {
            console.log("success");
            console.debug(data);
            $(traffic_element).html('<td></td><td>N</td>' + '<td>traffic</td>' + '<td>[' + data.mode + '] 花费时间 ' + data.traffic_time + '分</td>' + '<td></td>');
            $('#route-table tr:eq(' + row_index + ')').remove();
            $('#route-table tr:eq(' + row_index + ')').remove();
            return $('#route-table tbody tr').each(function(i, element) {
              return $(element).find('td:eq(1)').html(i + 1);
            });
          },
          error: function(xhr, ajaxOptions, thrownError) {
            $(traffic_element).html(traffic_html);
            return $("#result").html('请求失败！接口返回：' + xhr.responseJSON.error).addClass("alert alert-danger").show();
          }
        });
      } else {
        $('#route-table tr:eq(' + row_index + ')').remove();
        return $('#route-table tr:eq(' + row_index + ')').remove();
      }
    });
    $('.select-all').click(function() {
      return $('.route-select:checkbox').each(function(i, element) {
        var check_status;
        check_status = element.checked;
        console.log(element);
        console.log(check_status);
        if (check_status) {
          $(element).removeProp('checked');
          return $(this).html('反选');
        } else {
          $(element).prop('checked', 'checked');
          return $(this).html('全选');
        }
      });
    });
    return $('.update-route').click(function() {
      var button, params, pois;
      button = $(this);
      pois = [];
      $('.route-select:checkbox:checked').each(function(i, element) {
        return pois.push($(element).data('id'));
      });
      $("#result").hide();
      if (pois.length > 0) {
        params = {
          device_id: $('#device_id').val(),
          date: $('#date').val(),
          location: $('#location').val(),
          dislike_poiids: pois.join(','),
          uid: $('#uid').val(),
          route: $('#route').val()
        };
        return $.ajax({
          url: HOST + "api/demo/dayroutes/update.json",
          data: params,
          type: 'get',
          dataType: 'json',
          beforeSend: function() {
            return $(button).html('重新组合中...').prop('disabled', 'true');
          },
          success: function(data) {
            console.log("success");
            console.debug(data);
            output_daytours(data);
            $(button).html('重新推荐');
            return $("#result").html('路线已忽略选中的景点并重新推荐').addClass("alert alert-success").show();
          },
          error: function(xhr, ajaxOptions, thrownError) {
            console.log(xhr);
            $("#result").html('请求失败！接口返回：' + xhr.responseJSON.error).addClass("alert alert-danger").show();
            return $(button).html('重新推荐');
          },
          complete: function() {
            return $(button).removeProp('disabled');
          }
        });
      } else {
        return $("#result").html('你还没有选择景点').addClass("alert alert-warning").show();
      }
    });
  });

}).call(this);
