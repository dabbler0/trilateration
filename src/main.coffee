{DetectionContext, Vector} = require './trilateration.coffee'

canvas = document.querySelector 'canvas'
ctx = canvas.getContext '2d'

colors = {
  254: 'blue'
  253: 'red'
}

currentBuffers = {
  254: new Uint8Array(130)
  253: new Uint8Array(130)
}

window.addEventListener 'message', ((event) ->
  console.log event.data[1]
  currentBuffers[event.data[1]]?.set event.data
), false

render = (buffer) ->
  color = colors[buffer[1]]

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
