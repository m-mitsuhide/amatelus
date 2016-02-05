React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
request = require "superagent"
apiPath = require "../config.js"
Loading = require "./Loading.cjsx"
CloseBack = require "./CloseBack.cjsx"
action = require "../action/Preview_action.cjsx"

fs = require "fs"

TextField = MUI.TextField
RaisedButton = MUI.RaisedButton

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'
    savedState = localStorage.PreviewState;
    if ( savedState )
      state = JSON.parse( savedState )
    else
      state = {
        viewMode: "input",#input, preview, default
        inputTitle: null,
        error_inputTitle: null,
        complete: false,
        generated: false
      }


  else if action.type == "generated"
    state = Object.assign( {}, state, { generated: action.value } )

  state


class Preview extends React.Component
  constructor:(props)->
    super props
    @state = store.getState()
    store.subscribe ()=>
      @updateState()


  render:()->
    if @state.generated == false
      @generateFile();

    <div id="Preview">
      <CloseBack onClose={@onClose}/>
      {
        if @state.generated
          <webview disablewebsecurity src={"http://localhost:1337/" + @props.templateId + "/"} allowTransparency="true"/>
      }
      <div className="buttons">
        <RaisedButton primary={true} label="Generate" onClick={@props.onGenerate}/>
      </div>
      <Style type="Preview"/>
    </div>


  updateState:()->
    @setState store.getState()

  onClose: ()=>
    store.dispatch { type: "generated", value: false }
    @props.onClose()


  generateFile: ()=>
    store.dispatch { type: "generated", value: null }

    id = @props.templateId
    fs.readFile "./asset/template/" + id + "/data.json", "utf-8", ( err, json )->
      json = JSON.parse json

      n = 0
      ["goml","html","css","js"].forEach ( ext )=>
        fs.readFile "./asset/template/" + id + "/index." + ext, "utf-8", ( err, text )->
          text = text.replace /(["'])\/share\//g, "$1https://mitsuhide.jthird.net/share/"
          json[ ext ].forEach ( data )=>
            text = text.replace data.tag, data.value || ""

          fs.writeFile "./asset/template/" + id + "/preview/index." + ext, text, ( err )->
            if ++n == 4
              store.dispatch { type: "generated", value: true }

module.exports = Preview;
