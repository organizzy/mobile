

gulp         = require "gulp"
bower        = require "bower"
gutil        = require "gulp-util"
sh           = require "shelljs"
fs           = require "fs"

changed      = require "gulp-changed"
sourcemaps   = require "gulp-sourcemaps"
rename       = require "gulp-rename"
clean        = require "gulp-clean"
concat       = require "gulp-concat"

jade         = require 'gulp-jade'
minifyHTML   = require "gulp-minify-html"

coffee       = require 'gulp-coffee'
ngmin        = require 'gulp-ngmin'
uglify       = require 'gulp-uglify'

sass         = require "gulp-sass"
minifyCss    = require "gulp-minify-css"


# ------------------------
# --  CONSTANT
# ------------------------
SRC_DIR         = './src'
BUILD_DIR       = './www'
BOWER_DIR       = './bower_components'
#noinspection JSUnresolvedVariable
IS_PRODUCTION   = process.env.ENV is 'release'

# source directories
dirs =
  templates: "#{SRC_DIR}/templates"
  styles: "#{SRC_DIR}/stylesheets"
  scripts: "#{SRC_DIR}/scripts"

# paths
paths =
  src:
    index: ["#{SRC_DIR}/index.jade"]
    templates: ["#{dirs.templates}/**/*.jade"]
    scripts: ["#{dirs.scripts}/**/*"]
    styles: ["#{dirs.styles}/*"]
    ionic:
      js: "#{BOWER_DIR}/ionic/js/ionic.bundle.js"
      jsmin: "#{BOWER_DIR}/ionic/js/ionic.bundle.min.js"
      fonts: "#{BOWER_DIR}/ionic/fonts/*"

  dest:
    index: BUILD_DIR
    styles: "#{BUILD_DIR}/css"
    scripts: "#{BUILD_DIR}/js"
    templates: "#{BUILD_DIR}/templates"
    fonts: "#{BUILD_DIR}/fonts"
    images: "#{BUILD_DIR}/img"


# ----------------------------------------
# -----  TASKS ---------------------------
# ----------------------------------------

gulp.task "default", ["build"]

gulp.task "clean", ->
  gulp.src(BUILD_DIR, read: false)
  .pipe clean()

gulp.task "build", [
  'build:index'
  'build:scripts'
  'build:styles'
  'build:templates'
  'build:lib'
]


# -------- BUILD --------------

gulp.task "build:index", ->
  gulp.src(paths.src.index)
  .pipe changed(paths.dest.index, extension: '.html')
  .pipe jade()
  .pipe gulp.dest(paths.dest.index)

gulp.task "build:templates", ->
  gulp.src(paths.src.templates)
  .pipe changed(paths.dest.templates, extension: '.html')
  .pipe jade()
  .pipe gulp.dest(paths.dest.templates)

gulp.task 'build:scripts', ->
  gulp.src(paths.src.scripts)
  .pipe sourcemaps.init()
  .pipe concat('all.coffee')
  .pipe coffee()
  .pipe ngmin()
  .pipe uglify()
  .pipe sourcemaps.write("./", includeContent: false, sourceRoot: '/src')
  .pipe gulp.dest(paths.dest.scripts)


gulp.task "build:styles", ['lib:ionic'], ->
  gulp.src(paths.src.styles)
  .pipe changed(paths.dest.styles, extension: '.css')
  .pipe sourcemaps.init()
  .pipe sass()
  .pipe minifyCss()
  .pipe sourcemaps.write("./")
  .pipe gulp.dest(paths.dest.styles)

#-- Build library
gulp.task 'build:lib', ['build:lib:ionic']

gulp.task 'build:lib:ionic', ['build:lib:ionic:js', 'build:lib:ionic:fonts']

gulp.task 'build:lib:ionic:js', ['lib:ionic'], ->
  gulp.src(paths.src.ionic.js)
  .pipe changed(paths.dest.scripts)
  .pipe gulp.dest(paths.dest.scripts)

gulp.task 'build:lib:ionic:fonts', ['lib:ionic'], ->
  gulp.src(paths.src.ionic.fonts)
  .pipe changed(paths.dest.fonts)
  .pipe gulp.dest(paths.dest.fonts)


# --------------------------------------------- #
# --------------- LIBRARIES ------------------- #
# --------------------------------------------- #

bower_install = ->
  bower.commands.install().on "log", (data) ->
    gutil.log "bower", gutil.colors.cyan(data.id), data.message

ionicInstalled = false
gulp.task 'lib:ionic', (done) ->
  if ionicInstalled
    done()
  else if fs.existsSync("#{BOWER_DIR}/ionic")
    ionicInstalled = true
    done()
  else
    bower_install()
  gulp.run

gulp.task "watch", ->
  gulp.watch paths.src.index, ["build:index"]
  gulp.watch paths.src.scripts, ["build:scripts"]
  gulp.watch paths.src.styles, ["build:styles"]
  gulp.watch paths.src.templates, ["build:templates"]
  return

gulp.task "install", ["git-check"], -> bower_install()


gulp.task "git-check", (done) ->
  unless sh.which("git")
    console.log """
  #{gutil.colors.red("Git is not installed.")},
  Git, the version control system, is required to run Bower. Download git here: #{gutil.colors.cyan("http://git-scm.com/downloads")}
  Once git is installed, run #{gutil.colors.cyan("gulp install")} again.
"""
#"  " + gutil.colors.red("Git is not installed."), "\n  Git, the version control system, is required to run Bower.", "\n  Download git here:", gutil.colors.cyan("http://git-scm.com/downloads") + ".", "\n  Once git is installed, run '" + gutil.colors.cyan("gulp install") + "' again."
    process.exit 1
  done()
