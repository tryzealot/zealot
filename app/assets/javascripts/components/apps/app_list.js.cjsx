{table, tr, td} = React.DOM

@AppList = React.createClass
  displayName: 'AppList'
  render: ->
    appsNode = @props.data.map (app) ->
      <App key=app.id data=app />

    <table className="table table-striped table-bordered">
      <thead>
        <tr>
          <th>ID</th>
          <th>平台</th>
          <th>应用名称</th>
          <th>应用标识</th>
          <th>缩写</th>
          <th>上传版本数量</th>
          <th>操作</th>
        </tr>
      </thead>
      <tbody>
        {appsNode}
      </tbody>
    </table>