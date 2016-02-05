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

  changeTitle: ( text )->
    {
      type: 'changeTitle'
      value: text
    }

  changeThumbnail: ( name )->
    {
      type: 'changeThumbnail'
      value: name
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

  switchPreview: ( bool )->
    {
      type: "switchPreview",
      value: bool
    }

  saveDropData: ( list, templateId )->

    json = { goml: [], html: [], css: [], js: []}

    list.forEach ( data, idx )->
      tmp = {
        tag: data._tag
        type: null
        value: null
      }

      json[ data._ext ].push tmp

      if data.value
        if typeof data.value == "string"
          tmp.type = "text"
          tmp.value = data.value
        else
          tmp.value = []

          data.value.forEach ( file )->
            tmp.value.push "asset/" + file.name
            reader = new FileReader();
            reader.onload = (e)->
              buf = new Buffer(e.target.result.byteLength);
              source = new Uint8Array(e.target.result);
              for i in [0..e.target.result.byteLength]
                buf[i] = source[i];
              fs.writeFile "./asset/template/" + templateId + "/preview/asset/" + file.name, buf
            reader.readAsArrayBuffer file

          tmp.type = "file"

    fs.writeFile "./asset/template/" + templateId + "/data.json", JSON.stringify json

    #console.log(id,data,"saveDropData")
    {
      type: "saveDropData"
    }


}
