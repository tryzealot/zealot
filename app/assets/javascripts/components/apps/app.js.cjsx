{div, h3, tr, td} = React.DOM

@App = React.createClass
  displayName: 'App'

  _ConfirmDestory: ->
    return confirm("确定删除？")

  render: ->
    <tr>
      <td>{@props.data.id}</td>
      <td>{@props.data.device_type}</td>
      <td>
        <a href={Routes.app_path(@props.data.slug)}>{@props.data.name}</a>
      </td>
      <td>{@props.data.slug}</td>
      <td>{@props.data.password}</td>
      <td>{@props.data.count}</td>
      <td>
        <a href={Routes.releases_version_path(@props.data.slug)}>版本历史</a>
         /
        <a href={Routes.edit_app_path(@props.data.slug)}>编辑</a>
         /
        <a href={Routes.destroy_app_path(@props.data.slug)} onClick={@_ConfirmDestory}>删除</a>
      </td>
    </tr>