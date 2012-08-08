var fs = require('fs')
var sys = require('sys')
var exec = require('child_process').exec;

Array.prototype.diff = function(a) {
    return this.filter(function(i) {return !(a.indexOf(i) > -1);});
};


var x = function() {

}

var path = './tobewatched/'

var lastFiles = fs.readdirSync(path)
var processQueue = [ ]
console.log("Initial files:", lastFiles)


function processTheQueue() {
    if(processQueue.length < 1) {
        console.log("Empty queue... waiting")
        setTimeout(processTheQueue, 1000)
        return;
    }

    var currentFile = processQueue.pop()
    console.log("processing " + currentFile)
    exec('./process ' + currentFile, function(error, stdout, stderr) {
        console.log("processed: " + currentFile)
        setTimeout(processTheQueue, 0)
    });
}


fs.watch('./tobewatched/', function(changeType, filename) {
    if(changeType !== "rename") return;

    var oldFiles = lastFiles
    lastFiles = fs.readdirSync(path)
    var newFiles = lastFiles.diff(oldFiles)

    processQueue = processQueue.concat(newFiles)
});

processTheQueue()
