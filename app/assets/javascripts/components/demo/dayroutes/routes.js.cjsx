@Plans = React.createClass
  render: ->
    <div className="container">
      <div className="row">
        <div className="header">
          <h2>{@props.title}</h2>
          <div className="pull-right">
            <div key="gmap" className="map" />
          </div>
        </div>
      </div>
    </div>