React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
request = require "superagent"
apiPath = require "../config.js"
Loading = require "./Loading.cjsx"
CloseBack = require "./CloseBack.cjsx"
DropAsset = require "./DropAsset.cjsx"
TitleArea = require "./TitleArea.cjsx"

action = _action = require "../action/GenerateMode_action.cjsx"
fs = require "fs-extra"
ps = require "../js/pubsub.js"


Paper = MUI.Paper
RaisedButton = MUI.RaisedButton
FlatButton = MUI.FlatButton
IconButton = MUI.IconButton
ScreenRotation = require 'react-material-icons/icons/device/screen-rotation'

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'

    state = {
      templateId: null
      templateListArr: fs.readJsonSync "./asset/template/list.json"
      templateList: {}
      publicId: "preview"
      publicListArr: []
      publicList: {}
      viewSrc: ""
      rotation: false
      isLandscape: false
    }

    state.templateListArr.forEach ( list )->
      state.templateList[ list.id ] = list

  else if action.type == "setTemplateId"
    state = Object.assign {}, state, {
      templateId: action.templateId
      viewSrc: ""
      rotation: false
      isLandscape: false
      publicListArr: fs.readJsonSync "./public/" + action.templateId + "/list.json"
    }

    if !state.publicListArr.length
      state.publicListArr.unshift {
        title: "New content"
        id: "preview"
      }

    state.publicListArr.forEach ( list )->
      state.publicList[ list.id ] = list

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

  else if action.type == "offViewer"
    state = Object.assign {}, state, {
      viewSrc: ""
      }

  else if action.type == "changeTitle"
    state = Object.assign {}, state
    state.publicList.preview.title = action.value
    state.publicList[ state.publicId ].title = action.value
    fs.writeFile "./public/" + state.templateId + "/list.json", JSON.stringify state.publicListArr

  else if action.type == "changeThumbnail"
    state = Object.assign {}, state
    state.publicList.preview.thumbnail = action.value
    state.publicList[ state.publicId ].thumbnail = action.value
    fs.writeFile "./public/" + state.templateId + "/list.json", JSON.stringify state.publicListArr

  else if action.type == "changeContent"
    state = Object.assign {}, state
    state.publicId = action.value
    fs.copySync './public/' + state.templateId + "/" + state.publicId, "./public/" + state.templateId + "/preview"
    Object.assign state.publicList.preview, state.publicList[ state.publicId ], {id: "preview"}
    state.viewSrc =  _action.reloadViewer( state.templateId ).value
    ps.pub "GenerateMode.change", null, { publicId: state.publicId }

  else if action.type == "generate"
    state = Object.assign {}, state

    if state.publicId == "preview"
      state.publicId = state.publicListArr.length
      state.publicList[ state.publicId ] = Object.assign {}, state.publicList.preview
      state.publicList[ state.publicId ].id = state.publicId
      state.publicListArr.unshift state.publicList[ state.publicId ]

    else
      Object.assign state.publicList[ state.publicId ], state.publicList.preview
      state.publicList[ state.publicId ].id = state.publicId


    basePath = "./public/" + state.templateId + "/preview"
    fs.copySync basePath, './public/' + state.templateId + "/" + state.publicId
    fs.writeFile "./public/" + state.templateId + "/list.json", JSON.stringify state.publicListArr

    ###request = ajax.post( path.generate )
    request.field "id", templateId

    assets = fs.readdirSync( basePath + "asset" );

    assets.forEach ( name, idx )->
      request.attach idx, basePath + "asset/" + name

    ["goml","html","css","js"].forEach ( ext )->
      request.field ext, fs.readFileSync( basePath + "/index." + ext )

    request.end (err, res)->
      console.log err,res.text###

  state


class GenerateMode extends React.Component
  constructor:(props)->
    super props
    store.dispatch action.setTemplateId props.templateId
    @state = store.getState()

    store.subscribe ()=>
      @updateState()

  onChangeThumbnail: ( e )=>
    file = e.target.files[ 0 ]
    fs.unlink "./public/" + @state.templateId + "/preview/" + @state.publicList.preview.thumbnail, (err)=>
      fs.copy file.path, "./public/" + @state.templateId + "/preview/" + file.name, ( err )=>
        if !err
          if @state.publicId == "preview"
            store.dispatch action.changeThumbnail file.name
          else
            fs.unlink "./public/" + @state.templateId + "/" + @state.publicId + "/" + @state.publicList[ @state.publicId ].thumbnail, (err)=>
              fs.copy file.path, "./public/" + @state.templateId + "/" + @state.publicId + "/" + file.name, ( err )=>
                if !err
                  store.dispatch action.changeThumbnail file.name
    e.target.value = null

  render:()->
    templateId = @state.templateId
    publicId = @state.publicId

    <div id="GenerateMode">

      <div className="droper">
          <DropAsset
            templateId={@props.templateId}
            onPreview={()=>store.dispatch action.reloadViewer @props.templateId}
            onChange={(data)=>store.dispatch action.saveDropData data, @props.templateId}/>
      </div>
      <div className="result">
        <div className={ "device" + ( if @state.rotation then " rotation" else "")}>
          <img className="phone" src="./img/iphone.png"/>
          <div className={ "viewer" + ( if @state.isLandscape then " landscape" else "")}>
            <iframe src={@state.viewSrc}/>
          </div>
        </div>
        <TitleArea
          title={@state.publicList.preview.title}
          thumbnail={"url( ./public/" + @state.templateId + "/preview/" + @state.publicList.preview.thumbnail + ")"}
          onChangeTitle={(e)->store.dispatch action.changeTitle e.target.value}
          onChangeThumbnail={@onChangeThumbnail}
        />
        <IconButton onClick={()=>store.dispatch action.rotation @state.rotation, store} style={{position: "absolute", bottom: 62, left: 5}}>
          <ScreenRotation color="#666"/>
        </IconButton>

        <div className="generate">
          <FlatButton disabled={@state.viewSrc == ""} onClick={()->store.dispatch action.generate()} primary={true} style={{borderRight: "1px solid #eee"}} label={ if @state.publicId == "preview" then "Generate" else "Update"}/>
          <FlatButton disabled={@state.viewSrc == ""} onClick={()->store.dispatch action.offViewer()} secondary={true} label="Cancel"/>
        </div>

      </div>
      <div className="contents">
        {
          @state.publicListArr.map ( data, idx )->
            if data.id != "preview"
              <div key={idx} className={if data.id == publicId then "current" else ""}>
                <div className="panel" onClick={()->store.dispatch action.changeContent data.id} style={{backgroundImage: "url(./public/" + templateId + "/" + data.id + "/" + data.thumbnail + ")"}}>
                  <div>{data.title}</div>
                </div>
              </div>
        }
      </div>
      <Style type="GenerateMode"/>
    </div>


  updateState:()->
    @setState store.getState()

module.exports = GenerateMode;
