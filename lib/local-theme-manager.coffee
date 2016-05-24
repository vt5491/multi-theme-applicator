$ = jQuery = require 'jquery'
Utils = require './utils'
fs = require 'fs-plus'
path = require 'path'
less = require 'less'

module.exports =
  class LocalThemeManager

    constructor: ->
      @utils = new Utils()
      #@activeShadowRoot = @utils.getActiveShadowRoot()

    doIt: ->
      getActivePackages = atom.packages.getActivePackages
      7

    # return the active theme as a string
    # Note: this is defunct with the per buffer replacment design
    getActiveSyntaxTheme: ->
      console.log('LocalThemeManager.getActiveSyntaxTheme: entered')
      getActivePackages = atom.packages.getActivePackages
      # console.log('*******LocalThemeManager.getActiveSyntaxTheme: getActivePackages=' + getActivePackages + "\n")
      # console.log('***********************LocalThemeManager.getActiveSyntaxTheme: getActivePackages()=' + getActivePackages() + "\n")
      activePackages = atom.packages.getActivePackages()

      activeTheme = ''

      for pkg in activePackages
        if pkg.metadata.theme == 'syntax'
            activeTheme = pkg.metadata.name

      activeTheme

      # node1 = $('.pane').eq(1)
      # shadowRoot = $('.pane').eq(1).find('atom-text-editor').eq(0)[0].shadowRoot
      # #console.log('deleteThemeNode: shadowRoot=' + shadowRoot)
      #
      # node3 = $(shadowRoot)
      #   .find('atom-styles')
      #   .find('style').eq(2)
      #
      # console.log('injectClonedNode: node3=' + node3)
      # node4 = node3[0].parentNode.appendChild(clonedNode[0])
    addStyleElementToEditor: (styleElement)->
      shadowRoot = @utils.getActiveShadowRoot()

      $shadowRoot = $(shadowRoot)

      themeNode = $shadowRoot
        .find('[context="atom-text-editor"]')
        .filter('atom-styles')
        .append(styleElement)
        # .find('[priority="1"]')
        # .filter('[source-path*="index.less"]')

    deleteThemeStyleNode: ->
      console.log('LocalThemeManager.deleteThemeNode: now in deleteThemeNode')
      #node = $('atom-pane-axis:nth-child(2)')
      #node = $('atom-pane:eq(2)')
      #node1 = $('.pane:eq(1)')
      # node1 = $('.pane').eq(1)
      #node2 = $('atom-text-editor:eq(1)', node1)

      #node2 = $('.pane:eq(1) atom-text-editor:eq(1)')
      # shadowRoot = $('.pane').eq(1).find('atom-text-editor').eq(0)[0].shadowRoot
      shadowRoot = @utils.getActiveShadowRoot()
      #shadowRoot = @activeShadowRoot
      # shadowRoot = $('.pane').eq(1)
      #   .find('atom-text-editor::shadow').eq(0)
      console.log('deleteThemeNode: shadowRoot=' + shadowRoot)

      #jShadowRoot = $(shadowRoot)
      #node3 = jShadowRoot.$('atom-styles')
      #vt-x the following is the original
      # node3 = $(shadowRoot)
      #   .find('atom-styles')
      #   .find('style').eq(0)
      # #node3 = shadowRoot.find('atom-styles')
      # console.log('deleteThemeNode: node3=' + node3)
      # node3.remove()

      # new Code
      #$shadow.children().find('style').filter('[source-path*="index.less"]').filter('[priority="1"]')
      #$shadow.children().find('[context="atom-text-editor"]').filter('[priority="0"]').filter('[source-path*="bracket"]')
      #$shadowRoot.find('[context="atom-text-editor"]').filter('atom-styles').find('[priority="1"]').filter('[source-path*="index.less"]')
      $shadowRoot = $(shadowRoot)
      #styleNodes = $shadowRoot.children().find("[context='atom-text-editor']")

      #styleNodes.
      # themeNode = $shadowRoot
      #   .children()
      #   .find('[context="atom-text-editor"]')
      #   .filter('[priority="1"]')
      #   .filter('[source-path*="index.less"]')
      themeNode = $shadowRoot
        .find('[context="atom-text-editor"]')
        .filter('atom-styles')
        .find('[priority="1"]')
        .filter('[source-path*="index.less"]')

      if (themeNode.length != 1)
        console.log("LocalThemeManager.deleteThemeNode: could not properly identify the theme node")

        return -1

      themeNode.remove()
      # console.log('deleteThemeNode: deleted node3')


# less.render('.class { width: (1 + 1) }',
#     {
#       paths: ['.', './lib'],  // Specify search paths for @import directives
#       filename: 'style.less', // Specify a filename, for better error messages
#       compress: true          // Minify CSS output
#     },
#     function (e, output) {
#        console.log(output.css);
#     });
# /home/vturner/.atom/packages/humane-syntax

# // Load the file, convert to string
# fs.readFile( '../less/gaf.less', function ( error, data ) {
#   var dataString = data.toString();
#   var options = {
#     paths         : ["../less"],      // .less file search paths
#     outputDir     : "../css",   // output directory, note the '/'
#     optimization  : 1,                // optimization level, higher is better but more volatile - 1 is a good value
#     filename      : "gaf.less",       // root .less file
#     compress      : true,             // compress?
#     yuicompress   : true              // use YUI compressor?
#   };

 # fs.readFile( lessPath ,function(error,data){
 #        data = data.toString();
 #
 #        less.render(data, {
 #            paths: [ basePath + '/resources/assets/less/' ]
 #        },function (e, css) {
 #            fs.writeFile( outputPath, css.css, function(err){
 #                if( err ){
 #                    console.log(err );
 #                }
 #                console.log('done');
 #            });
 #        });
 #    });
    # getThemeCss: ->
    #   console.log('LocalThemeManager.getThemeCss: entered')
    #   basePath = '/home/vturner/.atom/packages/'
    #   lessPath = basePath + 'humane-syntax/index.less'
    #
    #   fs.readFile lessPath,
    #     (err, data) ->
    #       throw "cat: error reading from #{fn}: #{err}" if err
    #
    #       console.log "data=" + data
    #       data = data.toString()
    #
    #       options = {
    #         paths : ['/home/vturner/.atom/packages/humane-syntax/']
    #         filename : "index.less"
    #       }
    #
    #       less.render data, options, (e, css) ->
    #         console.log "genned css=" + css
    #         css

    # generate the css style text from the themes .less filej
    # TODO: I think I need to update this to return a promise
    # this is the promise version
    # getThemeCss: ->
    #   console.log('LocalThemeManager.getThemeCss: entered')
    #   basePath = '/home/vturner/.atom/packages/'
    #   lessPath = basePath + 'humane-syntax/index.less'
    #
    #   promise = new Promise (resolve, reject) ->
    #     fs.readFile lessPath, (err, data) ->
    #       throw "cat: error reading from #{fn}: #{err}" if err
    #
    #       console.log "data=" + data
    #       data = data.toString()
    #
    #       options = {
    #         paths : ['/home/vturner/.atom/packages/humane-syntax/']
    #         filename : "index.less"
    #       }
    #
    #       less.render data, options, (err, css) ->
    #         if err
    #           reject err
    #         else
    #           console.log "genned css=" + css
    #           resolve css
    #
    #       #promise
    getThemeCss: (basePath) ->
      console.log('LocalThemeManager.getThemeCss: entered')
      #basePath = '/home/vturner/.atom/packages/'
      #lessPath = basePath + 'humane-syntax/index.less'
      #lessPath = sourcePath || basePath + 'humane-syntax/index.less'
      lessPath = basePath + "/index.less"

      #promise = new Promise (resolve, reject) ->
      data = fs.readFileSync(lessPath, 'utf8')

      # fs.readFile lessPath, (err, data) ->
      #   throw "cat: error reading from #{fn}: #{err}" if err

      console.log "data=" + data
      data = data.toString()

      options = {
        #paths : ['.', './styles']
        paths : [basePath, basePath + '/styles']
        filename : "index.less"
      }

      promise = new Promise (resolve, reject) ->
        console.log "about to call less.render"
        less.render data, options, (err, result) ->
          console.log "now in less.render function handler"
          if err
            reject err
          else
            console.log "genned css=" + result.css.substring(0, 100)
            resolve result.css.toString()

    # getThemeCss: (sourcePath)->
    #   console.log('LocalThemeManager.getThemeCss: entered')
    #   basePath = '/home/vturner/.atom/packages/'
    #   lessPath = sourcePath || basePath + 'humane-syntax/index.less'

    syncEditorBackgroundColor: () ->
      shadowRoot = @utils.getActiveShadowRoot()

      # drill down to the background-color set by the local theme
      # This is a pretty convaluted way that was empirically determined.
      # There should probably be a better way.
      localStyleNode = $(shadowRoot)
        .find('atom-styles')
        .find('style').last()

      localBgColor = localStyleNode[0].sheet.rules[0].style.backgroundColor
      console.log 'syncEditorBackgroundColor: localBgColor=' + localBgColor

      activeTextEditor = atom.workspace.getActiveTextEditor()
      $(activeTextEditor).attr('style', 'background-color: ' + localBgColor)
