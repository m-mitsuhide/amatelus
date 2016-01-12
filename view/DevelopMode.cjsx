React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
request = require "superagent"
apiPath = require "../config.js"
Loading = require "./Loading.cjsx"
CloseBack = require "./CloseBack.cjsx"
DropAsset = require "./DropAsset.cjsx"

action = require "../action/DevelopMode_action.cjsx"

brace = require "brace"
AceEditor = require 'react-ace'

require 'brace/mode/javascript';
require 'brace/theme/chrome';

TextField = MUI.TextField
Paper = MUI.Paper
RaisedButton = MUI.RaisedButton
FloatingActionButton = MUI.FloatingActionButton
ToggleStar = MUI.ToggleStar

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'
    savedState = localStorage.DevelopModeState;
    if ( savedState )
      state = JSON.parse( savedState )
    else
      state = {
        viewMode: "input",#input, preview, default
        inputTitle: null,
        error_inputTitle: null,
        complete: false
      }

  else if action.type == "closeInput"
    state = {
      viewMode: "default"
      inputTitle: state.inputTitle,
      error_inputTitle: state.error_inputTitle,
      complete: state.complete
    }
  else if action.type == "inputTitle"
    state = {
      viewMode: state.viewMode,
      inputTitle: action.value,
      error_inputTitle: null,
      complete: false
    }

    if state.inputTitle == ""
      state.error_inputTitle = null
    else if !/^[0-9a-zA-Z]{5,15}$/.test state.inputTitle
      state.error_inputTitle = "Error"

    state.complete = state.inputTitle && !state.error_inputTitle

  state


class DevelopMode extends React.Component
  constructor:(props)->
    super props
    @state = store.getState()
    store.subscribe ()=>
      @updateState()

  render:()->
    <div id="DevelopMode">
      <div className="paper editor">
        <Paper zDepth={2}>
          <AceEditor
            mode="javascript"
            theme="chrome"
            onChange={()->console.log 99}
            name="UNIQUE_ID_OF_DIV"
            value={"function(){}"}
            fontSize={16}
            height={"100%"}
            width={"100%"}
            editorProps={{$blockScrolling: true}}
          />
        </Paper>
      </div>

      <div className="paper droper">
        <Paper zDepth={2}>
          <DropAsset />
        </Paper>
      </div>
      <Style type="DevelopMode"/>
    </div>


  updateState:()->
    @setState store.getState()

module.exports = DevelopMode;
