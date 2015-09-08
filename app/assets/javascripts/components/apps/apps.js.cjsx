{div, h3, tr, td} = React.DOM

@Apps = React.createClass
  displayName: 'Apps'
  getInitialState: ->
    didFetchData: false
    apps: []

  componentDidMount: ->
    @_fetchApps({})

  _fetchApps: (data) ->
    $.ajax
      url: Routes.apps_path()
      dataType: 'json'
      data: data
    .done @_fetchDataDone
    .fail @_fetchDataFail

  _fetchDataDone: (data, textStatus, jqXHR) ->
    return false unless @isMounted()
    console.log data
    @setState
      didFetchData: true
      apps: data


  _fetchDataFail: (xhr, status, err) ->
    console.error @props.url, status, err.toString()

  render: ->
    appNode = @state.apps.map (app) ->
      <App data={app} />

    <div className='apps'>
      <h3 className='title'>{@props.title}</h3>
      <AppList data={@state.apps} />
    </div>