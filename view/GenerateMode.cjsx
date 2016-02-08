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

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'
    savedState = localStorage.GenerateModeState;
    if ( savedState )
      state = JSON.parse( savedState )
    else
      state = {
        templateId: null,
        source: {},
        editorHash: {},
        worksArr: [],
        currentTab: "goml",
        saved: {},
        onPreview: false
        templateListArr: JSON.parse fs.readFileSync "./asset/template/list.json"
        templateList: {}
        currentTemplate: {}
        viewSrc: ""
      }

      state.templateListArr.forEach ( list )->
        state.templateList[ list.id ] = list

  else if action.type == "setTemplateId"
    state = Object.assign( {}, state, {
      templateId: action.templateId,
      worksArr: fs.readdirSync "./public/" + action.templateId
      currentTemplate: state.templateList[ action.templateId ]
    } )

  else if action.type == "saved"
    state.saved[ action.ext ] = true
  else if action.type == "reloadViewer"
    state = Object.assign {}, state, {
      viewSrc: action.value
      }

  else if action.type == "switchPreview"
    state = Object.assign( {}, state, {
      onPreview: action.value
      })

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
    @state = store.getState()
    store.dispatch action.setTemplateId props.templateId

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
        <div className="device">
          <img className="phone" src="./img/iphone.png"/>
          <div className="viewer">
            <webview src={@state.viewSrc} allowTransparency="true"/>
          </div>
        </div>
      </div>

      {
        if @state.onPreview
          <Preview templateId={@props.templateId}
            onClose={()->store.dispatch action.switchPreview false}
            onGenerate={()=>store.dispatch action.generate @props.templateId}
          />
      }

      <Style type="GenerateMode"/>
    </div>


  updateState:()->
    @setState store.getState()

module.exports = GenerateMode;
