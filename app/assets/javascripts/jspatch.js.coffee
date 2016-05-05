if $('#editor').length
  editor = ace.edit("editor")
  editor.setTheme("ace/theme/tomorrow_night")
  editor.getSession().setMode("ace/mode/javascript")
  editor.setValue($('#jspatch_script').html())
  editor.getSession().on('change', (e) ->
    $('#jspatch_script').html(editor.getValue())
  )