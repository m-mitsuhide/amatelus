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
            <div onClick={()->props.onClick(list.id)} style={{backgroundImage: "url(./asset/template/" + list.id + "/" + list.thumbnail + ")"}}>
              <div className="title" onClick={(e)->e.stopPropagation();props.onEdit(list.id)}>{list.title}</div>
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
