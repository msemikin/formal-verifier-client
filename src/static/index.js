// pull in desired CSS/SASS files
require( './styles/main.css' );

// inject bundled Elm app into div#main
var Elm = require( '../elm/Main' );
var app = Elm.Main.embed( document.getElementById( 'main' ) );

app.ports.save.subscribe(function (data) {
  splits = data.split('=')
  key = splits[0]
  data = splits[1]
  console.log('saving data with key: ' + key + " with data: " + data);
  window.localStorage.setItem(key, data);
});

app.ports.read.subscribe(function (key) {
  console.log('reading data for key', key);
  data = window.localStorage.getItem(key);
  app.ports.readResult.send(data || '');
});