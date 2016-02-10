React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
request = require "superagent"
apiPath = require "../config.js"
Loading = require "./Loading.cjsx"
CloseBack = require "./CloseBack.cjsx"
DropAsset = require "./DropAsset.cjsx"
Preview = require "./Preview.cjsx"

action = require "../action/GenerateMode_action.cjsx"
fs = require "fs"
ps = require "../js/pubsub.js"


Paper = MUI.Paper
RaisedButton = MUI.RaisedButton
FlatButton = MUI.FlatButton
IconButton = MUI.IconButton
ScreenRotation = require 'react-material-icons/icons/device/screen-rotation'

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'
    savedState = localStorage.GenerateModeState;
    if ( savedState )
      state = JSON.parse( savedState )
    else
      state = {
        templateId: null
        source: {}
        editorHash: {}
        worksArr: []
        currentTab: "goml"
        saved: {}
        templateListArr: JSON.parse fs.readFileSync "./asset/template/list.json"
        templateList: {}
        currentTemplate: {}
        viewSrc: ""
        rotation: false
        isLandscape: false
      }

      state.templateListArr.forEach ( list )->
        state.templateList[ list.id ] = list

  else if action.type == "setTemplateId"
    state = Object.assign( {}, state, {
      templateId: action.templateId
      viewSrc: ""
      rotation: false
      isLandscape: false
      worksArr: fs.readdirSync "./public/" + action.templateId
      currentTemplate: state.templateList[ action.templateId ]
    } )

  else if action.type == "rotation"
    state = Object.assign {}, state, {
      rotation: action.value
      }

  else if action.type == "rotationEnd"
    state = Object.assign {}, state, {
      isLandscape: state.rotation
      }

  else if action.type == "reloadViewer"
    state = Object.assign {}, state, {
      viewSrc: action.value
      }

  else if action.type == "generate"
    state = Object.assign( {}, state )
    state.worksArr.push attach.name


  state

ps.sub "GenerateMode.save", ( ctx, data )->
  state = store.getState()
  fs.writeFile "./asset/template/" + state.templateId + "/index." + data.ext, data.value, ()->
    store.dispatch action.saved data

class GenerateMode extends React.Component
  constructor:(props)->
    super props
    store.dispatch action.setTemplateId props.templateId
    @state = store.getState()

    store.subscribe ()=>
      @updateState()

  render:()->
    <div id="GenerateMode">

      <div className="droper">
          <DropAsset templateId={@props.templateId}
            onPreview={()=>store.dispatch action.reloadViewer @props.templateId}
            onChange={(data)=>store.dispatch action.saveDropData data, @props.templateId}/>
      </div>
      <div className="result">
        <div className={ "device" + ( if @state.rotation then " rotation" else "")}>
          <img className="phone" src="./img/iphone.png"/>
          <div className={ "viewer" + ( if @state.isLandscape then " landscape" else "")}>
            <webview src={@state.viewSrc} allowTransparency="true"/>
          </div>
        </div>
        <IconButton onClick={()=>store.dispatch action.rotation @state.rotation, store} style={{position: "absolute", top: 5, left: 5}}>
          <ScreenRotation/>
        </IconButton>
        <FlatButton onClick={@props.onPreview} primary={true} style={{position: "absolute", bottom: 0, width: "100%", height: 57, borderTop: "1px solid #eee" }} label="Generate"/>
      </div>

      <Style type="GenerateMode"/>
    </div>


  updateState:()->
    @setState store.getState()

module.exports = GenerateMode;
