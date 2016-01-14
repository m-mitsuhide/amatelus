fs = require "fs"
ps = require "../js/pubsub.js"

module.exports = {
  setTemplateId: ( templateId, onLoad )->
    source = {}
    l = 0

    ["goml","html","css","js"].forEach ( ext )->
      fs.readFile( "./asset/template/" + templateId + "/index." + ext, "utf-8", ( err, data )->
        source[ ext ] = data
        if ++l == 4
          onLoad source
      )

    {
      type: 'setTemplateId'
      templateId
    }

  setEditor: ( ext, e ) ->
    e.commands.addCommand( {
      name: "save"
      exec: (editor)-> ps.pub "DevelopMode.save", null, {
        ext
        value: editor.getSession().getValue()
      }
      bindKey: {
        mac: "cmd-s"
        win: "ctrl-s"
      }
    })

    {
      type: "setEditor"
      editor: e,
      ext
    }

  setSource: ( source ) ->

    {
      type: "setSource"
      source
    }

  changeTab: ( value ) ->
    {
      type: "changeTab"
      value
    }

  saved: ( data ) ->
    {
      type: "saved",
      ext: data.ext
    }


}
