var PubsubJS = require( "pubsubjs" ).create();

module.exports = {
  pub: function() {
    PubsubJS.publish.apply( PubsubJS, arguments );
  },
  sub: function() {
    PubsubJS.subscribe.apply( PubsubJS, arguments );
  },
  unsub: function() {
    PubsubJS.unsubscribe.apply( PubsubJS, arguments );
  }
};
