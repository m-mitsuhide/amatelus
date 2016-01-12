React = require 'react'
Redux = require 'redux'
reactDOM = require 'react-dom'
MUI = require 'material-ui'


Login = require './view/Login.cjsx'
ListMode = require './view/ListMode.cjsx'
DevelopMode = require "./view/DevelopMode.cjsx"

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
          <AppBar title={@state.userName}/>
      }
      {
        if @state.userName
          switch @state.viewMode
            when "develop"
              <DevelopMode />
            when "geneator"
              <div/>
            else#list
              <ListMode onSelect={
                (template_id)->store.dispatch action.selectTemplate template_id
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
