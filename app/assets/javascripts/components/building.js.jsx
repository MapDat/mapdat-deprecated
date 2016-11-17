var Building = React.createClass({
  propTypes: {
    name: React.PropTypes.string,
    abbrev: React.PropTypes.string,
    desc: React.PropTypes.string,
    imagePath: React.PropTypes.string,
    outlets: React.PropTypes.number,
    computers: React.PropTypes.bool,
    studySpace: React.PropTypes.bool,
    floors: React.PropTypes.number
  },

  render: function() {
    return (
      <div>
        <div>Name: {this.props.name}</div>
        <div>Abbrev: {this.props.abbrev}</div>
        <div>Desc: {this.props.desc}</div>
        <div>Image Path: {this.props.imagePath}</div>
        <div>Outlets: {this.props.outlets}</div>
        <div>Computers: {this.props.computers}</div>
        <div>Study Space: {this.props.studySpace}</div>
        <div>Floors: {this.props.floors}</div>
      </div>
    );
  }
});
