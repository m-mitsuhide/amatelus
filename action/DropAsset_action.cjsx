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

  setList: ( data )->
    list = {}
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
        tmp
    {
      type: "setList",
      list
    }
}
