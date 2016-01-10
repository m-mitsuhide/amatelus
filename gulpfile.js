'use strict';
var gulp = require('gulp');
var electron = require('electron-connect').server.create();

var sass     = require('gulp-ruby-sass');
var plumber  = require('gulp-plumber');

gulp.task('default', function () {

  // Electronの起動
  electron.start();

  gulp.watch(['sass/**/*.scss'], ['build:css']);

  // BrowserProcess(MainProcess)が読み込むリソースが変更されたら, Electron自体を再起動
  // gulp.watch(['.serve/app.js', '.serve/browser/**/*.js'], electron.restart);

  // RendererProcessが読み込むリソースが変更されたら, RendererProcessにreloadさせる
  gulp.watch(['Main.cjsx', 'index.html', '.serve/styles/**/*.css', './**/*.{html,css,js,cjsx}'], electron.reload);
});

gulp.task('build:css', function () {
  return sass(['sass/**/*.scss'], {compass: true})
    .pipe(gulp.dest('./css/'))
    .on('error', sass.logError);
})
