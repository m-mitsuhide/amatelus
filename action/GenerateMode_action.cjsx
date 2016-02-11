fs = require "fs-extra"
ps = require "../js/pubsub.js"
delimiter = require "../js/delimiter.js"
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

  changeTitle: ( value )->
    {
      type: 'changeTitle'
      value
    }

  changeThumbnail: ( value )->
    {
      type: 'changeThumbnail'
      value
    }

  changeContent: ( value )->
    {
      type: 'changeContent'
      value
    }

  generate: () ->
    {
      type: "generate"
    }

  reloadViewer: ( id )->

    json = JSON.parse fs.readFileSync "./public/" + id + "/preview/data.json", "utf-8"


    ["goml","html","css","js"].forEach ( ext )=>
      text = fs.readFileSync "./asset/template/" + id + "/index." + ext, "utf-8"

      json[ ext ].forEach ( data )=>
        text = text.replace data.tag, data.value || data.default || ""

      text = text.replace /(["'])\/share\//g, "$1https://mitsuhide.jthird.net/share/"

      fs.writeFileSync "./public/" + id + "/preview/index." + ext, text

    {
      type: "reloadViewer"
      value: "http://localhost:1337/generate/" + id + "/?" + Date.now()
    }

  offViewer: ()->
    {
      type: "offViewer"
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
            fs.copySync data.value[ 0 ].path.split( delimiter ).slice( 0, -1 ).join( "/" ), "./public/" + templateId + "/preview/asset/" + data._returned.split( "/" )[ 0 ]
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
                fs.writeFile "./public/" + templateId + "/preview/asset/" + file.name, buf
              reader.readAsArrayBuffer file

            if data.type == "file"
              tmp.value = tmp.value[ 0 ]


    fs.writeFile "./public/" + templateId + "/preview/data.json", JSON.stringify json

    {
      type: "saveDropData"
    }

  rotation: ( bool, store )->
    setTimeout ()->
      store.dispatch {
        type: "rotationEnd"
      }
    , 300

    {
      type: "rotation"
      value: !bool
    }

}
