{div, h3, tr, td} = React.DOM

@App = React.createClass
  displayName: 'App'
  # getinitialState: ->
  #   apps: @props.data
  # getDefaultProps: ->
  #   apps: []
  render: ->
    <tr>
      <td>{@props.data.id}</td>
      <td>{@props.data.device_type}</td>
      <td>{@props.data.name}</td>
      <td>{@props.data.identifier}</td>
      <td>{@props.data.slug}</td>
      <td>{@props.data.count}</td>
      <td>{@props.id}</td>
      <td></td>
    </tr>