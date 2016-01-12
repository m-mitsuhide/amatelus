React = require "react"
Redux = require 'redux'
MUI = require 'material-ui'
Style = require "./Style.cjsx"
request = require "superagent"
apiPath = require "../config.js"
Loading = require "./Loading.cjsx"
action = require "../action/Login_action.cjsx"
Background = require '../view/Background.cjsx'

TextField = MUI.TextField
AppBar = MUI.AppBar
Paper = MUI.Paper
RaisedButton = MUI.RaisedButton

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'
    state = {
      id: null,
      error_id: null,
      pass: null,
      error_pass: null,
      complete: false,
      loading: false
    }
  else if action.type == 'id'
    state = {
      id: action.value,
      error_id: null,
      pass: state.pass,
      error_pass: state.error_pass,
      loading: state.loading
    }

    if state.id == ""
      state.error_id = null
    else if !/^[0-9a-zA-Z]{5,15}$/.test state.id
      state.error_id = "Error"

    state.complete = state.id && state.pass && !state.error_id && !state.error_pass
  else if action.type == 'pass'
    state = {
      id: state.id,
      error_id: state.error_id,
      pass: action.value,
      error_pass: null,
      loading: state.loading
    }

    if state.pass == ""
      state.error_pass = null
    else if !/^[0-9a-zA-Z]{8,}$/.test state.pass
      state.error_pass = "Error"

    state.complete = state.id && state.pass && !state.error_id && !state.error_pass

  else if action.type == 'loading'
    state = {
      id: state.id,
      error_id: state.error_id,
      pass: state.pass,
      error_pass: state.error_pass,
      complete: state.complete,
      loading: true
    }

  else if action.type == 'loaded'

    if action.data.error
      state = {
        id: null,
        error_id: "Error",
        pass: null,
        error_pass: "Error",
        complete: false,
        loading: false
      }
    else
      action.onLogin action.data.name
  state


class Login extends React.Component
  constructor:(props)->
    super props
    @state = store.getState()
    store.subscribe ()=>
      @updateState()

  render:()->
    <div>
      <Background />
      <div id="Login">
        <div className="paper">
          <Paper zDepth={0}>
            <AppBar iconElementLeft={<span/>} title="Login" />
            <div className="input-area">
              <TextField errorText={@state.error_id} onInput={
                (e)->store.dispatch( action.inputId( e.target.value ) )
              } value={@state.id} hintText="alphanumeric from 5 to 15" floatingLabelText="id" />
              <TextField type="password" errorText={@state.error_pass} onInput={
                (e)->store.dispatch( action.inputPass( e.target.value ) )
              } value={@state.pass} hintText="alphanumeric 8 or more" floatingLabelText="password" />
              <div className="enter-btn">
                <RaisedButton label="Enter" disabled={!@state.complete} primary={true} onClick={@submit}/>
              </div>
            </div>
          </Paper>
          <Loading visible={@state.loading}/>
        </div>
        <Style type="Login"/>
      </div>
    </div>

  submit: () =>
    store.dispatch {
      type: "loading"
    }

    state = store.getState()

    request
      .post( apiPath.path.login )
      .type('form')
      .send({ id: state.id, pass: state.pass })
      .end(( err, req ) =>
        if err
          console.log("network error")
        else
          store.dispatch {
            type: "loaded",
            data: JSON.parse(req.text),
            onLogin: @props.onLogin
          }
      )

  updateState:()->
    @setState store.getState()

module.exports = Login;
