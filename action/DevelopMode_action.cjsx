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

      json[ data._ext ].push data

      if data.value && typeof data.value != "string"

        if data.type == "folder"
          fs.copySync data.value[ 0 ].path.split( delimiter ).slice( 0, -1 ).join( "/" ), "./asset/template/" + templateId + "/preview/asset/" + data._returned.split( "/" )[ 0 ]
          data.value = "asset/" + data._returned
        else
          tmp = []
          data.value.forEach ( file )->
            tmp.push "asset/" + file.name
            reader = new FileReader();
            reader.onload = (e)->
              buf = new Buffer(e.target.result.byteLength);
              source = new Uint8Array(e.target.result);
              for i in [0..e.target.result.byteLength]
                buf[i] = source[i];
              fs.writeFile "./asset/template/" + templateId + "/preview/asset/" + file.name, buf
            reader.readAsArrayBuffer file

          if data.type == "file"
            data.value = tmp[ 0 ]
          else
            data.value = tmp


    fs.writeFile "./asset/template/" + templateId + "/data.json", JSON.stringify json

    #console.log(id,data,"saveDropData")
    {
      type: "saveDropData"
    }

}
