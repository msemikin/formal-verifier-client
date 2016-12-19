// pull in desired CSS/SASS files
require( './styles/main.css' );
Viz = require('viz.js');

// inject bundled Elm app into div#main
var Elm = require( '../elm/Main' );
var app = Elm.Main.embed( document.getElementById( 'main' ) );

app.ports.save.subscribe(function (request) {
  var splits = request.split('=')
  var key = splits[0]
  var data = splits[1]
  console.log('saving data with key: ' + key + " with data: " + data);
  window.localStorage.setItem(key, data);
});

app.ports.read.subscribe(function (key) {
  console.log('reading data for key', key);
  var data = window.localStorage.getItem(key);
  app.ports.readResult.send(data || '');
});

app.ports.openDialog.subscribe(function () {
  var dialog = document.querySelector('dialog');
  setTimeout(function () {
    dialog.showModal();
  }, 0);
});

app.ports.closeDialog.subscribe(function () {
  var dialog = document.querySelector('dialog');
  dialog.open && dialog.close();
});

app.ports.generateDiagram.subscribe(function (src) {
  var diagram = Viz(src);
  app.ports.diagramResult.send(diagram);
});