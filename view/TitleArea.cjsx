React = require "react"
Style = require "./Style.cjsx"

MUI = require 'material-ui'
TextField = MUI.TextField

class TitleArea extends React.Component
  constructor:(props)->
    super props

  render:()->
    <div id="TitleArea">
      <div className="thumbnail">
        <div style={{ backgroundImage: @props.thumbnail}}>
          <input type="file" onChange={@props.onChangeThumbnail}/>
        </div>
      </div>
      <TextField className="input" onChange={
        @props.onChangeTitle
      } value={@props.title} hintText="Title"
      style={{
        fontSize: 20
        width: 300
        position: "absolute"
        top: 0
        left: 60
      }}
      inputStyle={{color: "#555"}}/>
      <Style type="TitleArea"/>
    </div>

module.exports = TitleArea;
