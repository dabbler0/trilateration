(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var frame;

frame = document.querySelector('iframe');

chrome.serial.getDevices(function(devices) {
  var buffer, j;
  chrome.serial.connect(devices[0].path, {
    bitrate: 115200
  }, function() {});
  buffer = new Uint8Array(130);
  j = 0;
  return chrome.serial.onReceive.addListener(function(info) {
    var el, i, k, len, pack, results, temp;
    temp = new Uint8Array(info.data);
    results = [];
    for (i = k = 0, len = temp.length; k < len; i = ++k) {
      el = temp[i];
      buffer[j] = el;
      j += 1;
      if (el === 255) {
        pack = new Uint8Array(130);
        pack.set(buffer);
        frame.contentWindow.postMessage(pack, '*');
        results.push(j = 0);
      } else {
        results.push(void 0);
      }
    }
    return results;
  });
});

},{}]},{},[1]);
