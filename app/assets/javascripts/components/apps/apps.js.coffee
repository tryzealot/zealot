{div, h3, tr, td} = React.DOM

@Apps = React.createClass
  displayName: 'Apps'
  # getinitialState: ->
  #   apps: @props.data
  # getDefaultProps: ->
  #   apps: []
  render: ->
    <div className='apps'>
      <h3 className='title'>{@props.title}</h3>
      <AppList data={@props.data} />
    </div>