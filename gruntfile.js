module.exports = function(grunt) {
    var NAME_MXMLC = 'mxmlc';
    var PATH_MXMLC = '../../node_modules/flex-sdk/lib/flex_sdk/bin/' + NAME_MXMLC;
    var TARGET_PLAYER = '11.9';

    var sys = require('sys')
    var exec = require('child_process').exec;

    grunt.loadNpmTasks('grunt-shell');
    grunt.loadNpmTasks("grunt-bumpup");
    grunt.loadNpmTasks("grunt-tagrelease");

    grunt.config.init({
        shell: {
            'clean dist': {
                command: 'rm -rf ./dist/'
            },
            'clean tmp': {
                command: 'rm -rf ./tmp/'
            },
            'mkdir tmp': {
                command: 'mkdir tmp',
            },
            'mkdir dist': {
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

                        // update path
                        var cmdWaveWorker = grunt.config('shell.worker-wave.command')
                            .replace(/_placeholder_/g, pathOfCompiler);

                        console.log('wave worker compiling command to exec: ', cmdWaveWorker);

                        grunt.config('shell.worker-wave.command', cmdWaveWorker);

                        var cmdMP3 = grunt.config('shell.worker-mp3.command')
                            .replace(/_placeholder_/g, pathOfCompiler);

                        console.log('core compiling command to exec: ', cmdMP3);

                        grunt.config('shell.worker-mp3.command', cmdMP3);

                        var cmdCore = grunt.config('shell.core.command')
                            .replace(/_placeholder_/g, pathOfCompiler);

                        console.log('core compiling command to exec: ', cmdCore);

                        grunt.config('shell.core.command', cmdCore);

                        done();
                    }
                }
            },
            'worker-wave': {
                command: '_placeholder_ workers/encoders/Wave.as -library-path+=../lib/ -output ../tmp/Worker.Encoder.Wave.swf -source-path+=./ -source-path+=../ext-src/promise-as3/src/ -source-path+=../ext-src/encoder-wave/src/ -target-player=' + TARGET_PLAYER,
                options: {
                    stdout: true,
                    stderr: true,
                    failOnError: true,
                    execOptions: {
                        cwd: 'src'
                    }
                }
            },
            'worker-mp3': {
                command: '_placeholder_ workers/encoders/MP3.as -library-path+=../lib/ -library-path+=../ext-src/encoder-mp3/lib/ -output ../tmp/Worker.Encoder.MP3.swf -source-path+=./ -source-path+=../ext-src/promise-as3/src/ -source-path+=../ext-src/encoder-wave/src/ -source-path+=../ext-src/encoder-mp3/src/ -target-player=' + TARGET_PLAYER,
                options: {
                    stdout: true,
                    stderr: true,
                    failOnError: true,
                    execOptions: {
                        cwd: 'src'
                    }
                }
            },
            'core': {
                command: '_placeholder_ Playcorder.as -library-path+=../lib/ -library-path+=../tmp/ -library-path+=../ext-src/encoder-mp3/lib/ -source-path+=./ -source-path+=../ext-src/promise-as3/src/ -source-path+=../tmp/ -source-path+=../ext-src/encoder-wave/src/ -source-path+=../ext-src/encoder-mp3/src/ -output ../dist/Playcorder.swf -target-player=' + TARGET_PLAYER,
                options: {
                    stdout: true,
                    stderr: true,
                    failOnError: true,
                    execOptions: {
                        cwd: 'src'
                    }
                }
            }
        },
        tagrelease: {
            file: 'package.json',
            commit:  true,
            message: 'Release %version%',
            prefix:  '',
            annotate: false
        },
        bumpup: {
            files: ['package.json']
        }
    });

    grunt.registerTask("default", "shell".split(' '));
    grunt.registerTask("release", function (type) {

        grunt.task.run('shell');
            
        if (type != null && type != false){
                grunt.task.run('bumpup:' + type);
                grunt.task.run('tagrelease');
        }

    });
};