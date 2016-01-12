React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
request = require "superagent"
apiPath = require "../config.js"
Loading = require "./Loading.cjsx"
CloseBack = require "./CloseBack.cjsx"
action = require "../action/ListMode_action.cjsx"

TextField = MUI.TextField
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


class ListMode extends React.Component
  constructor:(props)->
    super props
    @state = store.getState()
    store.subscribe ()=>
      @updateState()

  render:()->
    <div id="ListMode">
      {
        if @state.viewMode == "input"
          <div className="input-title">
            <CloseBack onClose={
              ()->store.dispatch action.closeInput()
            }/>
            <div className="paper">
              <Paper zDepth={2}>
                <div className="input-area">
                  <TextField errorText={@state.error_inputTitle} onInput={
                    (e)->store.dispatch( action.inputTitle( e.target.value ) )
                  } value={@state.inputTitle} hintText="alphanumeric from 5 to 15" floatingLabelText="Template id" />
                  <div className="enter-btn">
                    <RaisedButton label="Create" disabled={!@state.complete} primary={true} onClick={
                      ()=>action.submitTitle @state.inputTitle, @props.onSelect
                    }/>
                  </div>
                </div>
              </Paper>
            </div>
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
