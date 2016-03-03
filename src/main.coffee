{DetectionContext, Vector} = require './trilateration.coffee'

canvas = document.querySelector 'canvas'
ctx = canvas.getContext '2d'
freq = [1000]
FHT_N = 440
receivers = [
  new Vector(0, 0, 0),
  new Vector(-6.5, 0, 0),
  new Vector(0, -4.3, 0),
  new Vector(-2, 14, 0)
]
calibration = [
  [new Vector(10, 0, 0), 10],
  [new Vector(10, 0, 0), 10],
  [new Vector(10, 0, 0), 10],
  [new Vector(10, 0, 0), 10]
]
detectionContext = new DetectionContext(receivers, calibration)

colors = {
  254: 'blue'
  253: 'red'
  252: 'green'
  251: 'yellow'
}

currentBuffers = {
  254: new Uint8Array(130)
  253: new Uint8Array(130)
  252: new Uint8Array(130)
  251: new Uint8Array(130)
}

currentAmplitudes = [0, 0, 0, 0]
currentPosition = new Vector(0, 0, 0)

window.addEventListener 'message', ((event) ->
  console.log 255 - event.data[0], event.data[Math.floor(freq[0] * FHT_N / 44100) + 1]
  currentBuffers[event.data[0]]?.set event.data
  currentAmplitudes[255 - event.data[0] - 1] = event.data[Math.floor(freq[0] * FHT_N / 44100) + 1]
  currentPosition = detectionContext.detect(currentAmplitudes)
), false

render = (buffer) ->
  ctx.font = "48px serif";
  ctx.fillText(255 - buffer[0] + ": " + buffer[Math.floor(freq[0] * FHT_N / 44100) + 1], 10, 50 * (255 - buffer[0]))
  color = colors[buffer[0]]

  ctx.beginPath()
  ctx.moveTo 0, canvas.height
  for el, i in buffer when i isnt 0 and i isnt buffer.length - 1
    ctx.lineTo (i / buffer.length) * canvas.width, (1 - el / 255) * canvas.height
  ctx.lineTo canvas.width, canvas.height
  ctx.strokeStyle = color
  ctx.stroke()

  ctx.fillStyle = color
  ctx.globalAlpha = 0.5
  ctx.fill()

  ctx.globaAlpha = 1

tick = ->
  requestAnimationFrame tick
  ctx.clearRect 0, 0, canvas.width, canvas.height

  for key, buffer of currentBuffers
    render buffer

do tick
