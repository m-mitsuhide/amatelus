React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
request = require "superagent"
apiPath = require "../config.js"
Loading = require "./Loading.cjsx"
CloseBack = require "./CloseBack.cjsx"
action = require "../action/ListMode_action.cjsx"
fs = require 'fs'

GridList = require 'material-ui/lib/grid-list/grid-list';
GridTile = require 'material-ui/lib/grid-list/grid-tile';
StarBorder = require 'material-ui/lib/svg-icons/toggle/star-border';
IconButton = require 'material-ui/lib/icon-button';

TextField = MUI.TextField
Paper = MUI.Paper
RaisedButton = MUI.RaisedButton
FloatingActionButton = MUI.FloatingActionButton
AddBtn = require 'react-material-icons/icons/content/add';

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'
    state = {
      viewMode: "default",#input, preview, default
      inputTitle: null,
      error_inputTitle: null,
      complete: false,
      templateList: []
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
    @state.templateList = JSON.parse fs.readFileSync "./asset/template/list.json"

    store.subscribe ()=>
      @updateState()

  render:()->
    props = @props

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
      }
      {
        @state.templateList.map ( list, idx )->
          <div key={idx} templateId={list.id} className="panel" onClick={()->props.onClick(list.id)}>
            <img src={"./asset/template/" + list.id + "/" + list.thumbnail }/>
            <div className="title" onClick={(e)->e.stopPropagation();props.onEdit(list.id)}>{list.title}</div>
          </div>
      }

      <div className="btn-add">
        <FloatingActionButton secondary={true}>
          <AddBtn/>
        </FloatingActionButton>
      </div>
      <Style type="ListMode"/>
    </div>


  updateState:()->
    @setState store.getState()

module.exports = ListMode;
