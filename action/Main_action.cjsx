module.exports = {
  login: ( name )->
    {
      type: "login",
      name: name
    }
  selectTemplate: ( id )->
    {
      type: "selectTemplate",
      id: id
    }
}
