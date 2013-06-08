module.exports = function(grunt) {
    var PATH_MXMLC = '../../node_modules/flex-sdk/lib/flex_sdk/bin/mxmlc';

    grunt.loadNpmTasks('grunt-shell');

    grunt.config.init({
        shell: {
            'clean': {
                command: 'rm -rf ./dist/'
            },
            'mkdir': {
                command: 'mkdir dist',
            },
            'as3': {
                command: PATH_MXMLC + ' AudioHelper.as -library-path+=../../lib/ -output ../../dist/AudioHelper.swf',
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