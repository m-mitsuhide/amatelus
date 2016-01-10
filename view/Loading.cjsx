React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
CircularProgress = MUI.CircularProgress

class Loading extends React.Component
  constructor:(props)->
    super props

  render:()->
    <div id="Loading" style={{ display: if @props.visible then "block" else "none" }}>
      <div>
        <CircularProgress mode="indeterminate" size={2}/>
      </div>
      <Style type="Loading"/>
    </div>

module.exports = Loading;
