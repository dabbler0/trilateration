{DetectionContext, Vector} = require './trilateration.coffee'

canvas = document.querySelector 'canvas'
ctx = canvas.getContext '2d'
freq = [880]
FHT_N = 256
receivers = [
  new Vector(-4, -2, 0),
  new Vector(2, 2, 0),
  new Vector(-1, -3, 0),
  new Vector(5, -1, 0)
]
calibrationPoints = [
  new Vector(5, 0, 0)
  new Vector(0, 5, 0)
  new Vector(-5, 0, 0)
  new Vector(0, -5, 0)
  new Vector(0, 0, 5)
];
pro = 0

calibrationList = []

document.body.addEventListener 'keydown', ->
  if pro < calibrationPoints.length
    calibrationList.push {
      point: calibrationPoints[pro]
      amplitudes: currentAmplitudes
    }
    console.log {
      point: calibrationPoints[pro]
      amplitudes: currentAmplitudes
    }
    pro += 1

colors = {
  254: 'blue'
  253: 'red'
  252: 'green'
  251: 'yellow'
}

currentBuffers = {
  254: new Float64Array(130)
  253: new Float64Array(130)
  252: new Float64Array(130)
  251: new Float64Array(130)
}

currentAmplitudes = [0, 0, 0, 0]
currentPosition = new Vector(0, 0, 0)
detectionContext = null

window.addEventListener 'message', ((event) ->
  if event.data[0] >= 251
    #console.log 255 - event.data[0], event.data[Math.floor(freq[0] * FHT_N / 44100) + 1]
    converted = (2 ** (x / 16) for x in event.data)
    converted[0] = event.data[0]
    currentBuffers[event.data[0]]?.set converted
    currentAmplitudes[255 - event.data[0] - 1] = 2 ** (event.data[Math.floor(freq[0] * FHT_N / 44100) + 1] / 16)
    #console.log currentAmplitudes
    if !detectionContext and pro == calibrationPoints.length
      detectionContext = new DetectionContext(receivers, calibrationList)
      console.log "fully calibrated"
    if detectionContext
      currentPosition = detectionContext.detect(currentAmplitudes)
      console.log currentPosition
), false

render = (buffer) ->
  ctx.font = "30px serif";
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
