React = require 'react'
Redux = require 'redux'
reactDOM = require 'react-dom'
MUI = require 'material-ui'
tap = require 'react-tap-event-plugin'
tap()

Login = require './view/Login.cjsx'
ListMode = require './view/ListMode.cjsx'
DevelopMode = require "./view/DevelopMode.cjsx"
GenerateMode = require "./view/GenerateMode.cjsx"

action = require "./action/Main_action.cjsx"
AppBar = MUI.AppBar

store = Redux.createStore (state,action)->
  if typeof state == 'undefined'

    savedState = localStorage.MainState;
    if ( savedState )
      state = JSON.parse( savedState )
    else
      state = {
        userName: null,
        viewMode: null,#list, develop, generate
        templateId: null
      }
  else if action.type == 'login'
    state = {
      userName: action.name,
      viewMode: state.viewMode,
      templateId: state.templateId
    }
  else if action.type == 'logout'
    state = {
      userName: null,
      viewMode: null,
      templateId: null
    }
  else if action.type == 'selectTemplate'
    state = {
      userName: state.userName,
      viewMode: "develop",
      templateId: action.id
    }
  else if action.type == 'clickTemplate'
    state = Object.assign {}, state, {
      viewMode: "generate",
      templateId: action.id
    }
  else if action.type == 'editTemplate'
    state = Object.assign {}, state, {
      viewMode: "develop",
      templateId: action.id
    }
  else if action.type == 'goTop'
    state = Object.assign( {}, state, { viewMode: 'list' })

  if !state.viewMode
    state.viewMode = "list"

  localStorage.MainState = JSON.stringify( state );

  state

class MainComponent extends React.Component
  constructor:(props)->
    super props
    @state = store.getState();
    store.subscribe ()=>
      @updateState();

  render:()->
    <div>
      {
        if @state.userName
          <div id="header">
            <img className="logo" src="./img/logo.png" onClick={()->store.dispatch action.goTop()}/>
          </div>
      }
      {
        if @state.userName
          switch @state.viewMode
            when "develop"
              <DevelopMode templateId={@state.templateId}/>
            when "generate"
              <GenerateMode templateId={@state.templateId}/>
            else#list
              <ListMode onSelect={
                (template_id)->store.dispatch action.selectTemplate template_id
              } onClick={
                (template_id)->store.dispatch action.clickTemplate template_id
              } onEdit={
                (template_id)->store.dispatch action.editTemplate template_id
              }/>
        else
          <Login onLogin={
            (name)->store.dispatch action.login name
          }/>
      }
    </div>

  updateState:()->
    @setState store.getState()


reactDOM.render <MainComponent/>,document.getElementById('main')
