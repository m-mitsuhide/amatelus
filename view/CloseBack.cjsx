React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
FloatingActionButton = MUI.FloatingActionButton

class CloseBack extends React.Component
  constructor:(props)->
    super props

  render:()->
    <div id="CloseBack" onClick={@props.onClose}>
      <div>
        <FloatingActionButton primary={true}/>
      </div>
      <Style type="CloseBack"/>
    </div>

module.exports = CloseBack;
