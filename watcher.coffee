fs = require 'fs'
sys = require 'sys'
exec = require('child_process').exec

# Array.diff function taken from http://stackoverflow.com/questions/1187518/javascript-array-difference
Array.prototype.diff = (a) ->
    this.filter (i) ->
        not (a.indexOf(i) > -1)



class FileConverter
    constructor: (@processScript) ->
        @convertQueue = [ ]
        @convert()

    convertFiles: (files) ->
        @convertQueue.push file for file in files when @shouldConvert file

    shouldConvert: (file) ->
        true

    convert: =>
        if @convertQueue.length < 1
            console.log "Waiting for files to convert!"
            return setTimeout @convert, 1000

        currentFile = @convertQueue.pop()
        console.log "About to convert file #{currentFile}"
        exec "#{@processScript} #{currentFile}", (error, stdout, stderr) =>
            console.log "Converted file: #{currentFile}"
            setTimeout @convert, 0 # "Recursive" call without building up a stack



class AwesomeWatcher
    constructor: (@directory, @fileConverter) ->
        @lastFileListing = fs.readdirSync @directory
        fs.watch @directory, @watchEventCallback

    watchEventCallback: (changeType, filename) =>
        if changeType != "rename"
            return

        oldFiles = @lastFileListing
        @lastFileListing = fs.readdirSync(@directory)
        newFiles = @lastFileListing.diff oldFiles

        console.log "About to add #{newFiles} to the convertQueue"
        @fileConverter.convertFiles newFiles


# Initialize the whole shit
f = new FileConverter("./process")
new AwesomeWatcher('./tobewatched/', f)



