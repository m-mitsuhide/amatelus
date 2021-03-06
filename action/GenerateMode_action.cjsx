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

  toggleQR: ( value ) ->
    {
      type: "toggleQR"
      value
    }

  reloadViewer: ( id )->

    json_path = "./public/" + id + "/preview/data.json"
    if !fs.existsSync json_path
      fs.copySync "./asset/template/" + id + "/data.json", json_path
    json = JSON.parse fs.readFileSync json_path, "utf-8"


    ["goml","html","css","js"].forEach ( ext )=>
      text = fs.readFileSync "./asset/template/" + id + "/index." + ext, "utf-8"

      json[ ext ].forEach ( data )=>
        text = text.replace data._tag, data.value || data.default || ""

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
      json[ data._ext ].push data

      if data.value && typeof data.value != "string"

        if data.type == "folder"
          fs.copySync data.value[ 0 ].path.split( delimiter ).slice( 0, -1 ).join( "/" ), "./public/" + templateId + "/preview/asset/" + data._returned.split( "/" )[ 0 ]
          data.value = "asset/" + data._returned
        else
          tmp = []
          data.value.forEach ( file )->
            tmp.push "asset/" + file.name
            if /JPG$/.test file.name ##THETA resize
              img = new Image
              img.onload = ( e )->
                target = e.target;
                canvas = document.createElement "canvas"
                canvas.width = target.width / 2
                canvas.height = target.height / 2

                ctx = canvas.getContext "2d"
                ctx.drawImage e.target, 0, 0, canvas.width, canvas.height

                bin = atob(canvas.toDataURL( "image/jpeg" ).replace(/^.*,/, ''));
                buf = new Buffer bin.length
                for i in [0..bin.length]
                  buf[i] = bin.charCodeAt i
                fs.writeFile "./public/" + templateId + "/preview/asset/" + file.name, buf

                URL.revokeObjectURL e.target.src
              img.src = URL.createObjectURL file
            else
              reader = new FileReader();
              reader.onload = (e)->
                buf = new Buffer(e.target.result.byteLength);
                source = new Uint8Array(e.target.result);
                for i in [0..e.target.result.byteLength]
                  buf[i] = source[i];
                fs.writeFile "./public/" + templateId + "/preview/asset/" + file.name, buf
              reader.readAsArrayBuffer file

          if data.type == "file"
            data.value = tmp[ 0 ]
          else
            data.value = tmp


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
