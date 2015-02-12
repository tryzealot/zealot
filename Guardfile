# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features)

## Uncomment to clear the screen before every task
# clearing :on

## Guard internally checks for changes in the Guardfile and exits.
## If you want Guard to automatically start up again, run guard in a
## shell loop, e.g.:
##
##  $ while bundle exec guard; do echo "Restarting Guard..."; done
##
## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

guard 'sass', :input => 'sass', :output => 'css'

# This will concatenate the javascript files specified in :files to public/js/all.js
#
# Specifying every single file in the array like %w(a b c) to maintain the loading order is suggested - See https://github.com/makevoid/guard-concat for more info
#
guard :concat, type: "js", files: %w(), input_dir: "public/js", output: "public/js/all"

guard :concat, type: "css", files: %w(), input_dir: "public/css", output: "public/css/all"

###
# Sample Guardfile block for Guard::Uglify
#
# :input        - input file to compress
# :output       - file to write compressed output to
# :run_at_start - compressed input file when guard starts
# :uglifier     - options to be passed to the uglifier gem
###
guard "uglify", :input => "app/assets/javascripts/application.js", :output => "public/javascripts/application.js"

coffeescript_options = {
  input: 'app/assets/javascripts',
  output: 'app/assets/javascripts',
  patterns: [%r{^app/assets/javascripts/(.+\.(?:coffee|coffee\.md|litcoffee))$}]
}

guard 'coffeescript', coffeescript_options do
  coffeescript_options[:patterns].each { |pattern| watch(pattern) }
end
