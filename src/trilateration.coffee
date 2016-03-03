numeric = require 'numeric'

_fit = (A, b) ->
  left = numeric.dot numeric.transpose(A), A
  right = numeric.dot numeric.transpose(A), b

  return numeric.solve left, right

exports.Vector = class Vector
  constructor: (@x, @y, @z) ->

  magnitude: -> Math.sqrt @x * @x + @y * @y + @z * @z

  minus: (other) -> new Vector @x - other.x, @y - other.y, @z - other.z
  plus: (other) -> new Vector @x + other.x, @y + other.y, @z + other.z
  times: (other) -> new Vector @x * other, @y * other, @z * other

  scaleTo: (other) -> @times other / @magnitude()

  distance: (other) -> @minus(other).magnitude()

  array: -> [@x, @y, @z]

Vector.fromArray = (array) ->
  new Vector array[0], array[1], array[2]

exports.DetectionContext = class DetectionContext
  constructor: (@receivers, calibration) ->
    @calibration = (0 for _ in @receivers)
    @bias = (0 for _ in @receivers)

    # Least squares regression through the origin
    # to determine calibration coefficients for each detector
    for receiver, i in @receivers
      A = []
      b = []

      for {point, amplitudes} in calibration
        A.push [amplitudes[i], 1]
        b.push [1 / point.distance(@receivers[i])]

      regression = _fit A, b
      @calibration[i] = regression[0]
      @bias[i] = regression[1]

    # Designate the zeroth receiver
    # as the "base" receiver for our later linear regression
    @base = @receivers[0]

  detect: (amplitudes) ->
    distances = amplitudes.map (amplitude, i) => 1 / (amplitude * @calibration[i] + @bias[i])
    baseDistance = distances[0]

    # Our trilateration is based on the following:
    #
    # d0^2 = (x - x0)^2 + (y - y0)^2 + (z - z0)^2
    # d0^2 = (x^2 + y^2 + z^2) - 2xx0 - 2yy0 -2zz0 + (x0^2 + y0^2 + z0^2)
    # d0^2 - (x0^2 + y0^2 + z0^2) = (x^2 + y^2 + z^2) + (-2x)x0 + (-2y)y0 + (-2z)z0
    #
    # So doing linear regression of
    # d0^2 - (x0^2 + y0^2 + z0^2)
    # Against
    # 1 + (i)x0 + (j)y0 + (k)z0
    #
    # Should yeild (i) = -2x, (j) = -2y, (k) = -2z

    b = distances.map (r, i) => r ** 2 - @receivers[i].magnitude() ** 2
    A = @receivers.map (receiver) -> [receiver.x, receiver.y, receiver.z, 1]

    result = _fit A, b

    # Regressing gives us (x - b), so to get x, we add @base.
    return Vector.fromArray(result.map (x) -> x / (-2)).scaleTo Math.sqrt Math.abs result[3]
