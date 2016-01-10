React = require "react"


class Style extends React.Component
  constructor:(props)->
    super props

  render:()->
    <link rel="stylesheet" href={"./css/" + @props.type + ".css"} />

module.exports = Style;
