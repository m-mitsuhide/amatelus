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
  reloadViewer: ( id )->

    json = JSON.parse fs.readFileSync "./asset/template/" + id + "/data.json", "utf-8"


    ["goml","html","css","js"].forEach ( ext )=>
      text = fs.readFileSync "./asset/template/" + id + "/index." + ext, "utf-8"

      json[ ext ].forEach ( data )=>
        text = text.replace data.tag, data.value || data.default || ""

      text = text.replace /(["'])\/share\//g, "$1https://mitsuhide.jthird.net/share/"

      fs.writeFileSync "./asset/template/" + id + "/preview/index." + ext, text

    {
      type: "reloadViewer"
      value: "http://localhost:1337/" + id + "/?" + Date.now()
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
            fs.copySync data.value[ 0 ].path.split( "/" ).slice( 0, -1 ).join( "/" ), "./asset/template/" + templateId + "/preview/asset/" + data._returned.split( "/" )[ 0 ]
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
