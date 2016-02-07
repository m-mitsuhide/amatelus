fs = require "fs-extra"

module.exports = {
  createTemplate: ( onSelect )->
    hash = Date.now()
    fs.copySync "./asset/template/_basic", "./asset/template/" + hash
    json = JSON.parse fs.readFileSync "./asset/template/list.json"
    json.push {
      id: hash
      thumbnail: "default.jpg"
      title: "New Template"
    }
    fs.writeFileSync "./asset/template/list.json", JSON.stringify json
    fs.mkdirSync "./public/" + hash
    onSelect hash
}
