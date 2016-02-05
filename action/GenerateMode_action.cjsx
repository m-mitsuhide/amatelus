fs = require "fs-extra"
ps = require "../js/pubsub.js"
ajax = require "superagent"
path = require( "../config" ).path

module.exports = {
  setTemplateId: ( templateId )->

    {
      type: 'setTemplateId'
      templateId
    }

  saved: ( data ) ->
    {
      type: "saved",
      ext: data.ext
    }
  generate: ( templateId ) ->
    basePath = "./asset/template/" + templateId + "/preview/"
    name = Date.now()
    fs.copySync( basePath, './public/' + templateId + "/" + name );

    ###request = ajax.post( path.generate )
    request.field "id", templateId

    assets = fs.readdirSync( basePath + "asset" );

    assets.forEach ( name, idx )->
      request.attach idx, basePath + "asset/" + name

    ["goml","html","css","js"].forEach ( ext )->
      request.field ext, fs.readFileSync( basePath + "/index." + ext )

    request.end (err, res)->
      console.log err,res.text###

    {
      type: "generate",
      name
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
