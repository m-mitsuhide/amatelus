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
      value: templateId
    }

  setList: ( data, templateId, publicId )->
    list = {}
    publicData = if publicId then JSON.parse fs.readFileSync "./public/" +  templateId + "/" + publicId + "/data.json"

    for key of data
      arr = data[ key ].match( /<%.+?%>/g ) || []
      list[ key ] = Array.prototype.map.call arr, ( val )->
        text = val.replace( "<%", "" ).replace( "%>", "" ).trim()
        tmp = {
          _tag: val
          _returned: ""
        }
        text.split( " " ).map ( t )->
          tmp[ t.split( "=" )[ 0 ] ] = t.split( "=" )[ 1 ].replace( /('|")/g, "" )
        publicData && Object.assign tmp, publicData[ key ][ +tmp.index ]
        tmp


    {
      type: "setList"
      list
      publicId
    }

  createSnippet: ( bool )->
    {
      type: "createSnippet"
      value: bool
    }
  changeSnippetType: ( value )->
    {
      type: "changeSnippetType"
      value
    }
  snippetTitle: ( value )->
    {
      type: "snippetTitle"
      value
    }
  snippetDefault: ( value )->
    {
      type: "snippetDefault"
      value
    }
  generate: ( value, onInsert )->
    {
      type: "generate"
      value
      onInsert
    }
}
