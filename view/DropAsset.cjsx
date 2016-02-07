React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
request = require "superagent"
apiPath = require "../config.js"
Loading = require "./Loading.cjsx"
CloseBack = require "./CloseBack.cjsx"

action = require "../action/DropAsset_action.cjsx"

ps = require "../js/pubsub.js"


TextField = MUI.TextField
AppBar = MUI.AppBar
Paper = MUI.Paper
RaisedButton = MUI.RaisedButton
FloatingActionButton = MUI.FloatingActionButton
ToggleStar = MUI.ToggleStar
AddBtn = require 'react-material-icons/icons/content/add'

SelectField = MUI.SelectField
MenuItem = MUI.MenuItem

clipboard = require "clipboard"

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'

    state = {
      templateId: null,
      list: {},
      listArr: []
      createSnippet: false
      snippetType: "text"
      completeSnippet: false
      snippetTitle: ""
      snippetDefault: ""
      error_snippetTitle: ""
      error_snippetDefault: ""
    }

  else if action.type == "setTemplateId"
    state = Object.assign( {}, state, { templateId: action.templateId } )
    state.listArr.length = 0

  else if action.type == "setList"

    state = Object.assign( {}, state, { list: Object.assign( state.list, action.list ) } )
    tmpArr = [];
    for key of state.list
      state.list[ key ].forEach ( data )->
        data._ext = key
        tmp = state.listArr[ +data.index ]
        if tmp && tmp.type == data.type
          data.value = tmp.value
          data._returned = tmp._returned

        tmpArr[ +data.index ] = data

    state.listArr = tmpArr

  else if action.type == "createSnippet"
    state = Object.assign {}, state, {
      createSnippet: action.value
      }

  else if action.type == "changeSnippetType"
    state = Object.assign {}, state, {
      snippetType: action.value
      }

  else if action.type == "snippetTitle"
    state = Object.assign {}, state, {
      snippetTitle: action.value
      error_snippetTitle: if / /.test action.value then "Can't use space." else ""
      }

    state.completeSnippet = action.value != "" && state.error_snippetTitle == "" && state.error_snippetDefault == ""

  else if action.type == "snippetDefault"
    state = Object.assign {}, state, {
      snippetDefault: action.value
      error_snippetDefault: if / /.test action.value then "Can't use space." else ""
      }

    state.completeSnippet = state.snippetTitle != "" && state.error_snippetTitle == "" && state.error_snippetDefault == ""

  else if action.type == "generate"
    tag = '<% index="' + state.listArr.length + '" type="' + state.snippetType + '" title="' + state.snippetTitle + '"' + ( if state.snippetDefault == "" then "" else ' default="' + state.snippetDefault + '"' ) + ' %>'
    if action.value == "insert"
      action.onInsert tag
    else
      clipboard.writeText tag

    state = Object.assign {}, state, {
      createSnippet: false
      snippetType: "text"
      completeSnippet: false
      snippetTitle: ""
      snippetDefault: ""
      error_snippetTitle: ""
      error_snippetDefault: ""
      }

  state


class DropAsset extends React.Component
  constructor:(props)->
    super props
    @state = store.getState()
    store.dispatch action.setTemplateId props.templateId, ( data )->
      store.dispatch action.setList data

    ps.sub "DevelopMode.save", @saved
    store.subscribe ()=>
      @updateState()

  saved: ( ctx, data )=>
    tmp = {}
    tmp[ data.ext ] = data.value
    store.dispatch action.setList tmp
    @props.onChange @state.listArr

  componentWillUnmount: ()->
    ps.unsub "DevelopMode.save", @saved

  render:()->
    props = @props

    <div id="DropAsset">
      <div className="list-box">
        {
          @state.listArr.map ( item, idx ) ->
            <div key={idx} className={if item._returned == "" then "" else "dropped"}>
              <div className="dragHandler"/>
              <div className="drop-area">
                <span className="drop-title">{item.title}</span>
                {
                  switch item.type
                    when "text"
                      <TextInput index={idx} onChange={props.onChange}/>
                    when "file"
                      <FileDropper index={idx} onChange={props.onChange}/>
                }
                {
                  if item.type != "text"
                  then <span className="drop-value">{item._returned}</span>
                  else null
                }
              </div>
            </div>
        }
      </div>
      <RaisedButton onClick={@props.onPreview} primary={true} style={{position: "absolute", bottom: 10, right: 10, left: 10 }} label="Preview"/>
      <Style type="DropAsset"/>
      {
        if @props.mode == "develop"
          <FloatingActionButton style={{position: "absolute", bottom: 65, right: 10}} primary={true} onClick={
            ()->store.dispatch action.createSnippet true
            }>
            <AddBtn/>
          </FloatingActionButton>
      }

      {
        if @state.createSnippet
          <div className="snippet">
            <CloseBack onClose={()->store.dispatch action.createSnippet false}/>
            <Paper className="frame" zDepth={2}>
              <AppBar iconElementLeft={<span/>} title="Generate snippet" />
              <div className="input-area">
                <SelectField value={@state.snippetType} onChange={(event, idx, val)->store.dispatch action.changeSnippetType val}>
                  <MenuItem value="text" primaryText="Text"/>
                  <MenuItem value="file" primaryText="File"/>
                </SelectField>

                <TextField errorText={@state.error_snippetTitle} onInput={
                  (e)->store.dispatch( action.snippetTitle( e.target.value ) )
                } value={@state.snippetTitle} floatingLabelText="title" />
                <TextField errorText={@state.error_snippetDefault} onInput={
                  (e)->store.dispatch( action.snippetDefault( e.target.value ) )
                } value={@state.snippetDefault} floatingLabelText="default" />
                <div className="enter-btn">
                  <RaisedButton label="Insert" style={{float: "left"}} disabled={!@state.completeSnippet} primary={true} onClick={()->store.dispatch action.generate "insert", props.onInsert}/>
                  <RaisedButton label="Copy" style={{float: "right"}} disabled={!@state.completeSnippet} primary={true} onClick={()->store.dispatch action.generate "copy"}/>
                </div>
              </div>
            </Paper>
          </div>
      }
    </div>


  updateState:()->
    @setState store.getState()

module.exports = DropAsset;

class TextInput extends React.Component
  constructor:(props)->
    super props
    @state = store.getState()
    store.subscribe ()=>
      @setState store.getState()

  onInput: (e)=>
    list = @state.listArr
    list[ @props.index ].value = e.target.value
    list[ @props.index ]._returned = e.target.value

    @props.onChange( list )
  render:()->
    <TextField hintText="Text" value={@state.listArr[ @props.index ]._returned} style={{width:"100%"}} onInput={@onInput} />




class FileDropper extends React.Component
  constructor:(props)->
    super props

    @store = Redux.createStore (state,action)->
      if typeof state == 'undefined'
        state = {
          isDrag: false
        }
      else if action.type == "dragEnter"
        state = {
          isDrag: true
        }
      else if action.type == "dragLeave"
        state = {
          isDrag: false
        }

      state

    @state = @store.getState()
    @store.subscribe ()=>
      @updateState()

  updateState:()=>
    @setState @store.getState()

  onDragEnter:()=>
    @store.dispatch { type: "dragEnter" }

  onDragLeave:()=>
    @store.dispatch( { type: "dragLeave" } )

  onDragOver:( e )->
    e.stopPropagation()
    e.preventDefault()
    e.dataTransfer.dropEffect = 'copy'

  onDrop: ( e )=>
    e.preventDefault()
    @store.dispatch( { type: "dragLeave" } )

    files = []
    index = @props.index
    _this = @

    length = e.dataTransfer.items.length
    counter = length

    traverseFileTree = (item, path)->

      path = path || ""
      if item.isFile
        ##Get file
        item.file (file)->
          files.push( file );
          file.path = path + file.name;

          if --counter == 0
            _this.dataExchange( files, index );


      else if item.isDirectory
        ##Get folder contents
        dirReader = item.createReader();

        dirReader.readEntries (entries)->
          counter += entries.length;
          for i in [0..entries.length-1]
            traverseFileTree(entries[i], path + item.name + "/");

          if --counter == 0
            _this.dataExchange( files, index )

    for i in [0..length-1]
      traverseFileTree(e.dataTransfer.items[i].webkitGetAsEntry());

  onChange: (e)=>
    files = []

    Array.prototype.forEach.call e.target.files, ( file )->
      file.path = file.webkitRelativePath;
      files.push( file );

    @dataExchange( files, @props.index )
    e.target.value = null;

  dataExchange: ( files, index )=>
    list = store.getState().listArr
    list[ index ].value = files
    list[ index ]._returned = files.map( ( file )->
      file.name ).join ","

    @props.onChange list

  render: ()->
    <form className={ if @state.isDrag then "dropper on" else "dropper" } method="post" encType="multipart/form-data">
      <span>File</span>
      <input type="file" className="form-control" webkitdirectory directory
        onDragEnter={@onDragEnter}
        onDragLeave={@onDragLeave}
        onDrop={@onDrop}
        onDragOver={@onDragOver}
        onChange={@onChange}
      />
    </form>
