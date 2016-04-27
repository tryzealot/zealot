{div, h3, tr, td, button, h4} = React.DOM
Promise = $.Deferred

Modal = React.createClass(
  displayName: 'Modal'
  backdrop: ->
    <div className='modal-backdrop in' />
  modal: ->
    style = display: 'block'
    <div
      className='modal in'
      tabIndex='-1'
      role='dialog'
      aria-hidden='false'
      ref='modal'
      style={style}
    >
      <div className='modal-dialog'>
        <div className='modal-content'>
          {this.props.children}
        </div>
      </div>
    </div>
  render: ->
    <div>
      {this.backdrop()}
      {this.modal()}
    </div>
)

Confirm = React.createClass(
  displayName: 'Confirm'
  getDefaultProps: ->
    confirmLabel: 'OK'
    abortLabel: 'Cancel'
  abort: ->
    @promise.reject()
  confirm: ->
    @promise.resolve()
  componentDidMount: ->
    @promise = new ($.Deferred)
    React.findDOMNode(@refs.confirm).focus()
  render: ->
    React.createElement Modal, null,
      div
        className: 'modal-header'
        h4 className: 'modal-title', @props.message
      if @props.description
        div
          className: 'modal-body'
          @props.description
      div
        className: 'modal-footer'
        div
          className: 'text-right'
          button
            role: 'abort'
            type: 'button'
            className: 'btn btn-default'
            onClick: @abort
            @props.abortLabel
          ' '
          button
            role: 'confirm'
            type: 'button'
            className: 'btn btn-primary'
            ref: 'confirm'
            onClick: @confirm
            @props.confirmLabel
)

confirm = (message, options = {}) ->
  props = $.extend({message: message}, options)
  wrapper = document.body.appendChild(document.createElement('div'))
  component = React.render(React.createElement(Confirm, props), wrapper)
  cleanup = ->
    React.unmountComponentAtNode(wrapper)
    setTimeout -> wrapper.remove()
  component.promise.always(cleanup).promise()

@App = React.createClass
  displayName: 'App'

  _confirmDestory: (context, url) ->
    confirm('确认删除?')
      .then( ->
        $.ajax
          url: url
          dataType: 'json'
        .done ->
          console.log 'success'
          $('tr#app-row-' + context.props.data.id).remove()
        .fail ->
          console.log 'fail'
      )

  render: ->
    <tr id={"app-row-" + @props.data.id}>
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
        <a href="#" data-id={@props.data.id} onClick={@_confirmDestory.bind(this, this,  Routes.destroy_app_path(@props.data.slug))}>删除</a>
      </td>
    </tr>