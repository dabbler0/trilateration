# Test simulation for trilateration.
#
# The trilateration algorithm turns out to be very sensitive to noise --
# We can't tolerate very well any more noise than around half a percent
# of the signal.

{Vector, DetectionContext} = require './trilateration.coffee'

MAX = 50
NOISE = 0.005

_rand = -> new Vector(Math.random() * 2 * MAX - MAX, Math.random() * 2 * MAX - MAX, Math.random() * 2 * MAX - MAX)

class GenerationContext
  constructor: (@receivers, calibration, @mutes, @ambients, @config) ->
    @detectionContext = new DetectionContext @receivers, calibration

  test: (point) ->
    console.log 'POINT', point
    amplitudes = @receivers.map((receiver, i) =>
      @config.volume * @mutes[i] / receiver.distance(point) +
      @ambients[i] +
      Math.random() * @config.noise)
    console.log 'DETECTED', @detectionContext.detect amplitudes

GenerationContext.createRandom = (volume = 100, noise = volume * NOISE / MAX, n = 4, c = 100) ->
  receivers = []
  for i in [0...n]
    receivers.push _rand()

  receiverMutes = (Math.random() for el, i in receivers)
  ambients = (Math.random() for el, i in receivers)

  # Random calibration
  calibration = []
  for i in [0...c]
    point = _rand()
    amplitudes = receivers.map((receiver, i) -> volume * receiverMutes[i] / receiver.distance(point) + ambients[i] + Math.random() * noise)

    calibration.push {amplitudes, point}

  return new GenerationContext(receivers, calibration, receiverMutes, ambients, {volume, noise})

ctx = GenerationContext.createRandom()

ctx.test _rand()
