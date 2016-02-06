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
      }

  else if action.type == "setTemplateId"
    state = Object.assign( {}, state, {
      templateId: action.templateId,
      worksArr: fs.readdirSync "./public/" + action.templateId
    } )

  else if action.type == "saved"
    state.saved[ action.ext ] = true

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
    store.dispatch action.setTemplateId props.templateId, ( data )->
      store.dispatch action.setSource data

    store.subscribe ()=>
      @updateState()


  render:()->
    <div id="GenerateMode">

      <div className="paper droper">
        <Paper zDepth={2}>
          <DropAsset templateId={@props.templateId}
            onPreview={()->store.dispatch action.switchPreview true}
            onChange={(data)=>store.dispatch action.saveDropData data, @props.templateId}/>
        </Paper>
      </div>
      <div className="paper works">
        {
          @state.worksArr.map (name, idx)->
            <div key={idx}></div>
        }
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
