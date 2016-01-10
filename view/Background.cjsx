React = require "react"
Style = require "./Style.cjsx"


class Background extends React.Component
  constructor:(props)->
    super props

  render:()->
    <div id="Background">
      <div/>
      <Style type="Background"/>
    </div>

module.exports = Background;
