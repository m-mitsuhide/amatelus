React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
request = require "superagent"
apiPath = require "../config.js"
Loading = require "./Loading.cjsx"

action = require "../action/DropAsset_action.cjsx"



TextField = MUI.TextField
Paper = MUI.Paper
RaisedButton = MUI.RaisedButton
FloatingActionButton = MUI.FloatingActionButton
ToggleStar = MUI.ToggleStar

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'
    savedState = localStorage.DropAssetState;
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


class DropAsset extends React.Component
  constructor:(props)->
    super props
    @state = store.getState()
    store.subscribe ()=>
      @updateState()

  render:()->
    tmp = [
      {
        type: "image",
        multi: false,
        title: "sample"
      },
      {
        type: "image",
        multi: false,
        title: "sample"
      },
      {
        type: "image",
        multi: false,
        title: "sample"
      }
    ]
    <div id="DropAsset">
      <div className="list-box">
        {
          tmp.map ( item, idx ) ->
            <div key={idx}>
              <div className="dragHandler"/>
              <div className="drop-area">
                {item.title+idx}
              </div>
            </div>
        }
      </div>
      <RaisedButton primary={true} style={{position: "absolute", bottom: 10, right: 10, left: 10 }} label="Preview"/>
      <Style type="DropAsset"/>
    </div>


  updateState:()->
    @setState store.getState()

module.exports = DropAsset;
