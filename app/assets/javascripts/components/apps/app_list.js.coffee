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
          <th>Platform</th>
          <th>App Name</th>
          <th>Identifier</th>
          <th>slug</th>
          <th>Uploaded Count</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        {appsNode}
      </tbody>
    </table>
    # @props.apps.map (app) ->
    #   div null,
    #     app.name