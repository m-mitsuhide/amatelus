React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
request = require "superagent"
apiPath = require "../config.js"
Loading = require "./Loading.cjsx"
action = require "../action/ListMode_action.cjsx"

TextField = MUI.TextField
AppBar = MUI.AppBar
Paper = MUI.Paper
RaisedButton = MUI.RaisedButton
FloatingActionButton = MUI.FloatingActionButton
ToggleStar = MUI.ToggleStar

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'
    savedState = localStorage.ListModeState;
    if ( savedState )
      state = JSON.parse( savedState )
    else
      state = {
        viewMode: "input"#input, preview, null
      }

  state


class ListMode extends React.Component
  constructor:(props)->
    super props
    @state = store.getState()
    store.subscribe ()=>
      @updateState()

  render:()->
    <div id="ListMode">
      <AppBar title="Title"/>
      {
        if @state.viewMode == "input"
          <div className="input-title">
          </div>
        else
          <div className="btn-add">
            <FloatingActionButton secondary={true}>
            </FloatingActionButton>
          </div>
      }
      <Style type="ListMode"/>
    </div>


  updateState:()->
    @setState store.getState()

module.exports = ListMode;
