module.exports = function(grunt) {
    var NAME_MXMLC = 'mxmlc';
    var PATH_MXMLC = '../../node_modules/flex-sdk/lib/flex_sdk/bin/' + NAME_MXMLC;

    var sys = require('sys')
    var exec = require('child_process').exec;

    grunt.loadNpmTasks('grunt-shell');

    grunt.config.init({
        shell: {
            'clean': {
                command: 'rm -rf ./dist/'
            },
            'mkdir': {
                command: 'mkdir dist',
            },
            'config': {
                command: 'which ' + NAME_MXMLC,
                options: {
                    callback: function(err, stdout, stderr, done) {
                        var pathOfCompiler = '';

                        if (err 
                            || 
                            // check against empty string
                            stdout == false) {

                            pathOfCompiler = PATH_MXMLC;

                        }
                        else{

                            pathOfCompiler = NAME_MXMLC;

                        }

                        var cmd = grunt.config('shell.as3.command')
                            .replace(/_placeholder_/g, pathOfCompiler);

                        console.log('command to exec: ', cmd);

                        grunt.config('shell.as3.command', cmd);

                        done();
                    }
                }
            },
            'as3': {
                command: '_placeholder_ AudioHelper.as -library-path+=../../lib/ -output ../../dist/AudioHelper.swf',
                options: {
                    stdout: true,
                    stderr: true,
                    failOnError: true,
                    execOptions: {
                        cwd: 'src/as'
                    }
                }
            }
        }

    });

    grunt.registerTask("default", "shell".split(' '));

    
};