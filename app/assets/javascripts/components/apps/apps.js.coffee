{div, h3, tr, td} = React.DOM

@Apps = React.createClass
  getinitialState: ->
    apps: @props.data
    console.log apps
  getDefaultProps: ->
    apps: []
  render: ->
    div
      className: 'apps'
      h3
        className: 'title'
        'Apps'