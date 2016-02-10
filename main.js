'use strict';

const electron = require('electron');
// Module to control application life.
const app = electron.app;
//app.commandLine.appendSwitch('remote-debugging-port', '8315');
//app.commandLine.appendSwitch('host-rules', 'MAP * 127.0.0.1');
// Module to create native browser window.
const BrowserWindow = electron.BrowserWindow;

var client = require('electron-connect').client;
// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

function createWindow () {
  // Create the browser window.
  mainWindow = new BrowserWindow({width: 800, height: 600});
  mainWindow.setMenu( null );

  // and load the index.html of the app.
  mainWindow.loadURL('file://' + __dirname + '/index.html');

  // Open the DevTools.
  mainWindow.webContents.openDevTools();

  // Emitted when the window is closed.
  mainWindow.on('closed', function() {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null;
  });

  client.create(mainWindow);
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
app.on('ready', createWindow);

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', function () {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow();
  }
});


/*Web コンテンツを開発するための Node.js 簡易 Web サーバー サンプル*/
//Web サーバーが Listen する IP アドレス
var LISTEN_IP = '127.0.0.1';
//Web サーバーが Listen する ポート
var LISTEN_PORT = 1337;
//ファイル名が指定されない場合に返す既定のファイル名
var DEFAULT_FILE = "index.html";

var http = require('http');
var fs = require( "fs" );
var url = require( "url" );

//拡張子を抽出
function getExtension(fileName) {
    var fileNameLength = fileName.length;
    var dotPoint = fileName.indexOf('.', fileNameLength - 5 );
    var extn = fileName.substring(dotPoint + 1, fileNameLength);
    return extn;
}

//content-type を指定
function getContentType(fileName) {
    var extentsion = getExtension(fileName).toLowerCase();
    var contentType = {
        'html': 'text/html',
        'htm' : 'text/htm',
        'css' : 'text/css',
        'js' : 'text/javaScript; charset=utf-8',
        'json' : 'application/json; charset=utf-8',
        'xml' : 'application/xml; charset=utf-8',
        'jpeg' : 'image/jpeg',
        'jpg' : 'image/jpg',
        'gif' : 'image/gif',
        'png' : 'image/png',
        'mp3' : 'audio/mp3',
        'pmx' : 'application/pmx;',
        'vmd' : 'application/vmd;',
        };
        var contentType_value = contentType[extentsion];
        if(contentType_value === undefined){
            contentType_value = 'text/plain';};
    return contentType_value;
}

//Web サーバーのロジック
var server  = http.createServer();
var ajax = require( "superagent" );

server.on('request',
    function(request, response){

        var requestedFile = url.parse(request.url,true).pathname;
        var templateId = requestedFile.split("/")[1];

        requestedFile = (requestedFile.split("").pop() === '/')
? requestedFile + DEFAULT_FILE : requestedFile;
        //console.log('Handle Url:' + requestedFile);
        //console.log('File Extention:' + getExtension( requestedFile));
        //console.log('Content-Type:' + getContentType( requestedFile));

        if ( /^\/share\//.test( requestedFile ) ) {
          ajax
            .get( "https://mitsuhide.jthird.net" + requestedFile )
            .set( "Referer", "http://localhost" )
            .end( function( err, req ) {
              for (var key in req.body ) {
                //console.log("test" + key);
              }
              if(err){
                  response.writeHead(404, {'Content-Type': 'text/plain'});
                  response.write('not found\n');
                  response.end();
              }else{
                  response.writeHead(200, {'Content-Type': getContentType(requestedFile)});
                  response.write(req.body, "binary");
                  response.end();
              }
            })
        } else {
          fs.readFile('asset/template/' + templateId + "/preview" + decodeURIComponent( requestedFile.split(templateId)[1] ),'binary', function (err, data) {
              if(err){
                  response.writeHead(404, {'Content-Type': 'text/plain'});
                  response.write('not found\n');
                  response.end();
              }else{
                  response.writeHead(200, {'Content-Type': getContentType(requestedFile)});
                  response.write(data, "binary");
                  response.end();
              }
          });
        }
    }
);

server.listen(LISTEN_PORT, LISTEN_IP);
console.log('Server running at http://' + LISTEN_IP + ':' + LISTEN_PORT);
