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

action = require "../action/DevelopMode_action.cjsx"
fs = require "fs-extra"
ps = require "../js/pubsub.js"

brace = require "brace"
AceEditor = require 'react-ace'

require 'brace/mode/javascript';
require 'brace/mode/xml';
require 'brace/mode/html';
require 'brace/mode/css';
require 'brace/theme/chrome';

TextField = MUI.TextField
Paper = MUI.Paper
RaisedButton = MUI.RaisedButton
FloatingActionButton = MUI.FloatingActionButton
ToggleStar = MUI.ToggleStar
Tabs = MUI.Tabs
Tab = MUI.Tab

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'
    savedState = localStorage.DevelopModeState;
    if ( savedState )
      state = JSON.parse( savedState )
    else
      state = {
        templateId: null
        templateList: []
        currentData: {}
        error_title: false
        source: {}
        editorHash: {}
        editorArr: []
        currentTab: "goml"
        saved: {}
        onPreview: false
      }

  else if action.type == "setTemplateId"
    newList = JSON.parse fs.readFileSync "./asset/template/list.json"
    state = Object.assign {}, state, {
      templateId: action.templateId
      templateList: newList
      currentData: newList.filter( ( data )->
        if data.id == action.templateId then data else false )[ 0 ]
    }

  else if action.type == "changeTitle"
    state = Object.assign {}, state, {
      error_title: if action.value == "" then "No title" else null
    }
    state.currentData.title = action.value
    fs.writeFile "./asset/template/list.json", JSON.stringify state.templateList

  else if action.type == "changeThumbnail"
    state = Object.assign {}, state
    state.currentData.thumbnail = action.value
    fs.writeFile "./asset/template/list.json", JSON.stringify state.templateList


  else if action.type == "setEditor"
    state = Object.assign( {}, state )

    state.editorHash[ action.ext ] = action.editor
    state.editorArr.push action.editor

  else if action.type == "setSource"
    state = Object.assign {}, state

    for key of action.source
      state.saved[ key ] = if state.saved[ key ] == undefined || state.source[ key ] == action.source[ key ] then true else false
    state.source = Object.assign {}, state.source, action.source

    state.editorArr.forEach ( e )->
      e.resize()
  else if action.type == "changeTab"
    state = Object.assign( {}, state, {
      currentTab: action.value
    })
  else if action.type == "saved"
    state.saved[ action.ext ] = true

  else if action.type == "switchPreview"
    state = Object.assign( {}, state, {
      onPreview: action.value
      })

  state

ps.sub "DevelopMode.save", ( ctx, data )->
  state = store.getState()
  fs.writeFile "./asset/template/" + state.templateId + "/index." + data.ext, data.value, ()->
    store.dispatch action.saved data

class DevelopMode extends React.Component
  constructor:(props)->
    super props
    @state = store.getState()
    store.dispatch action.setTemplateId props.templateId, ( data )->
      store.dispatch action.setSource data

    store.subscribe ()=>
      @updateState()

  onChangeThumbnail: ( e )=>
    file = e.target.files[ 0 ]
    fs.unlink "./asset/template/" + @state.templateId + "/" + @state.currentData.thumbnail, (err)=>
      fs.copy file.path, "./asset/template/" + @state.templateId + "/" + file.name, ( err )->
        if !err
          store.dispatch action.changeThumbnail file.name
    e.target.value = null

  insertSnippet: ( tag )=>
    editor = @state.editorHash[ @state.currentTab ];
    editor.insert tag
    editor.focus()

  componentWillUnmount: ()->
    fs.emptyDir "./asset/template/" + @state.templateId + "/preview/asset/"

  render:()->
    <div id="DevelopMode">
      <div className="title">
        <div className="thumbnail">
          <div style={{ backgroundImage: "url( ./asset/template/" + @state.templateId + "/" + @state.currentData.thumbnail + ")"}}>
            <input type="file" onChange={@onChangeThumbnail}/>
          </div>
        </div>
        <TextField className="input" errorText={@state.error_title} onChange={
          (e)->store.dispatch( action.changeTitle( e.target.value ) )
        } value={@state.currentData.title} hintText="Template Title"
        style={{
          fontSize: 20
          width: 300
          position: "absolute"
          top: 5
          left: 70
        }} />
      </div>
      <div className="paper editor">
        <Paper zDepth={2}>
          <Tabs value={@state.currentTab}>
            <Tab label={"GOML" + if @state.saved.goml == false then "*" else ""} value="goml" onClick={()->store.dispatch action.changeTab "goml"}>
              <div/>
            </Tab>
            <Tab label={"HTML" + if @state.saved.html == false then "*" else ""} value="html" onClick={()->store.dispatch action.changeTab "html"}>
              <div/>
            </Tab>
            <Tab label={"CSS" + if @state.saved.css == false then "*" else ""} value="css" onClick={()->store.dispatch action.changeTab "css"}>
              <div/>
            </Tab>
            <Tab label={"JS" + if @state.saved.js == false then "*" else ""} value="js" onClick={()->store.dispatch action.changeTab "js"}>
              <div/>
            </Tab>
          </Tabs>
          <div style={{
            display: if @state.currentTab == "goml" then "block" else "none"
          }}>
            <AceEditor
              mode="xml"
              theme="chrome"
              onChange={( text )->store.dispatch action.setSource { "goml": text }}
              name="UNIQUE_ID_OF_DIV0"
              value={@state.source.goml}
              fontSize={16}
              width="100%"
              height="auto"
              editorProps={{$blockScrolling: Infinity}}
              onLoad={(e)->store.dispatch action.setEditor "goml", e }
            />
          </div>
          <div style={{
            display: if @state.currentTab == "html" then "block" else "none"
          }}>
            <AceEditor
              mode="html"
              theme="chrome"
              onChange={( text )->store.dispatch action.setSource { "html": text }}
              name="UNIQUE_ID_OF_DIV1"
              value={@state.source.html}
              fontSize={16}
              width="100%"
              height="auto"
              editorProps={{$blockScrolling: Infinity}}
              onLoad={(e)->store.dispatch action.setEditor "html", e }

            />
          </div>
          <div style={{
            display: if @state.currentTab == "css" then "block" else "none"
          }}>
            <AceEditor
              mode="css"
              theme="chrome"
              onChange={( text )->store.dispatch action.setSource { "css": text }}
              name="UNIQUE_ID_OF_DIV2"
              value={@state.source.css}
              fontSize={16}
              width="100%"
              height="auto"
              editorProps={{$blockScrolling: Infinity}}
              onLoad={(e)->store.dispatch action.setEditor "css", e }

            />
          </div>
          <div style={{
            display: if @state.currentTab == "js" then "block" else "none"
          }}>
            <AceEditor
              mode="javascript"
              theme="chrome"
              onChange={( text )->store.dispatch action.setSource { "js": text }}
              name="UNIQUE_ID_OF_DIV3"
              value={@state.source.js}
              fontSize={16}
              width="100%"
              height="auto"
              editorProps={{$blockScrolling: Infinity}}
              onLoad={(e)->store.dispatch action.setEditor "js", e }

            />
          </div>
        </Paper>
      </div>

      <div className="paper droper">
        <Paper zDepth={2}>
          <DropAsset templateId={@props.templateId} mode="develop"
            onInsert={@insertSnippet}
            onPreview={()->store.dispatch action.switchPreview true}
            onChange={(data)=>store.dispatch action.saveDropData data, @props.templateId}/>
        </Paper>
      </div>
      {
        if @state.onPreview
          <Preview templateId={@props.templateId} onClose={()->store.dispatch action.switchPreview false}/>
      }

      <Style type="DevelopMode"/>
    </div>


  updateState:()->
    @setState store.getState()

module.exports = DevelopMode;
