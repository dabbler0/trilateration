chrome.app.runtime.onLaunched.addListener ->
  chrome.app.window.create 'window.html',
    outerBounds:
      width: 500
      height: 500
