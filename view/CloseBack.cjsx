React = require "react"
Style = require "./Style.cjsx"
ClearBtn = require 'react-material-icons/icons/content/clear';

class CloseBack extends React.Component
  constructor:(props)->
    super props

  render:()->
    <div id="CloseBack" onClick={@props.onClose}>
      <div>
        <ClearBtn color="#fff"/>
      </div>
      <Style type="CloseBack"/>
    </div>

module.exports = CloseBack;
