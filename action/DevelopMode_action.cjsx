fs = require "fs"

module.exports = {
  closeInput: ()->
    {
      type: 'closeInput'
    }
  inputTitle: ( text )->
    {
      type: 'inputTitle',
      value: text
    }
  submitTitle: ( title, onSelect )->
    fs.mkdirSync( "./asset/template/" + title )
    onSelect( title )
}
