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
    fs.writeJsonSync "./asset/template/list.json", json
    fs.mkdirsSync "./public/" + hash + "/preview/asset"
    fs.writeJsonSync "./public/" + hash + "/list.json", []
    onSelect hash
}
