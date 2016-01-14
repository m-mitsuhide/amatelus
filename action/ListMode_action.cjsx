fs = require "fs-extra"

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
    fs.copySync( "./asset/template/_basic", "./asset/template/" + title )
    onSelect( title )
}
