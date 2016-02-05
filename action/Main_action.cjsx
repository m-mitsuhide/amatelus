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
  goTop: ()->
    {
      type: "goTop"
    }
  clickTemplate: ( id )->
    {
      type: 'clickTemplate',
      id
    }
  editTemplate: ( id )->
    {
      type: 'editTemplate',
      id
    }
}
