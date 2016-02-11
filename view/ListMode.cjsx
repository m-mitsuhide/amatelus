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
IconButton = MUI.IconButton
FloatingActionButton = MUI.FloatingActionButton
AddBtn = require 'react-material-icons/icons/content/add'
DevelopBtn = require 'react-material-icons/icons/action/build'
GenerateBtn = require 'react-material-icons/icons/editor/mode-edit'

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'
    state = {
      viewMode: "default"# preview, default
      templateList: []
    }

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
        @state.templateList.map ( list, idx )->
          <div key={idx} className="panel">
            <div style={{backgroundImage: "url(./asset/template/" + list.id + "/" + list.thumbnail + ")"}}>
              <div className="title">{list.title}</div>
              <div className="tools">
                <IconButton onClick={()->props.onEdit(list.id)} tooltip="Develop" touch={true} tooltipPosition="top-center" style={{position: "absolute", top: "50%", left: "35%", transform: "translate( -50%, -50%)"}}>
                  <DevelopBtn color="#fff"/>
                </IconButton>
                <IconButton onClick={()->props.onClick(list.id)} tooltip="Generate" touch={true} tooltipPosition="top-center" style={{position: "absolute", top: "50%", left: "65%", transform: "translate( -50%, -50%)"}}>
                  <GenerateBtn color="#fff"/>
                </IconButton>
              </div>
            </div>
          </div>
      }

      <div className="btn-add">
        <FloatingActionButton secondary={true} onClick={
          ()=>action.createTemplate @props.onSelect
          }>
          <AddBtn/>
        </FloatingActionButton>
      </div>
      <Style type="ListMode"/>
    </div>


  updateState:()->
    @setState store.getState()

module.exports = ListMode;
