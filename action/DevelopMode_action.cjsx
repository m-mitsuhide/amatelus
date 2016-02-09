fs = require "fs-extra"
ps = require "../js/pubsub.js"
delimiter = require "../js/delimiter.js"

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
        type: data.type
        value: null
      }

      if data.default then tmp.default = data.default

      json[ data._ext ].push tmp

      if data.value
        if typeof data.value == "string"
          tmp.value = data.value
        else

          if data.type == "folder"
            tmp.value = "asset/" + data._returned
            fs.copySync data.value[ 0 ].path.split( delimiter ).slice( 0, -1 ).join( "/" ), "./asset/template/" + templateId + "/preview/asset/" + data._returned.split( "/" )[ 0 ]
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

            if data.type == "file"
              tmp.value = tmp.value[ 0 ]


    fs.writeFile "./asset/template/" + templateId + "/data.json", JSON.stringify json

    #console.log(id,data,"saveDropData")
    {
      type: "saveDropData"
    }

}
