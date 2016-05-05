function search_user_status()
{
  $('#search_user_status').attr('disabled', 'disabled');
  var client_id = $.trim($('#client_id').html());

  if (client_id == null || client_id == "")
  {
    $('#search_user_status').html("箭扣 ID 为空，不能查询，重新刷新本页面");
    return;
  }

  var search_count = 0;
  console.log("search user status: %s", client_id);

  for(var i = 0; i < groups.length; i++)
  {
    var group = groups[i];
    $.ajax({
      type: 'get',
      url: 'http://api.im.qyer.com/v1/im/topic_info.json',
      dataType: 'json',
      data: { key: '2WcCvCk0FxNt50LnbCQ9SFcACItvuFNx', id: group['id'], content_format: 'map' }
    }).done(function(json){
      search_count += 1;

      if (json.meta.code == 200)
      {
        var group_id = json.response.topic.id;
        var group_name = json.response.topic.name.replace(/^discuss_/i, '');
        var members = json.response.topic.parties;
        var joined_at = null;

        console.log("search no: %d/%d ", search_count, groups.length, group_name);
        console.log(json);

        $('#search_user_status').html("查询聊天室：" + group_name + "...");
        for (var index in members)
        {
          var member = members[index];
          Object.keys(member).forEach(function(key) {
            if (client_id == key) joined_at = member[key];
          });
        }

        if (joined_at != null)
        {
          $('#chatroom-ds').css('display', 'block');
          $('#chatroom-ds table').append('<tr><td>' + group_id +  '</td><td>' + group_name + '</td><td>' + group['type'] + '</td><td>' + joined_at + '</td></tr>');
        }

        if (groups.length == search_count)
        {
          search_count = 0;
          $('#search_user_status').html("再次查询");
          $('#search_user_status').removeAttr('disabled');
        }
      }
    });
  }
}

$(document).ready(function(){
  $('#search_user_status').click(function(){
    search_user_status();
  });
});