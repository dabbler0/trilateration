frame = document.querySelector 'iframe'

chrome.serial.getDevices (devices) ->
  chrome.serial.connect devices[0].path, {bitrate: 115200}, ->

  buffer = new Uint8Array(130); j = 0

  chrome.serial.onReceive.addListener (info) ->
    temp = new Uint8Array(info.data)
    for el, i in temp
      buffer[j] = el; j += 1
      if el is 255
        pack = new Uint8Array(130); pack.set buffer
        frame.contentWindow.postMessage pack, '*'
        j = 0
