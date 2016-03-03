three = require 'three'

SCALE = 20

# Setup
scene = new three.Scene()
camera = new three.PerspectiveCamera(
  75, window.innerWidth / window.innerHeight, 0.1, 1000
)

camera.position.x =
  camera.position.y =
  camera.position.z = SCALE

camera.up.set 0, 0, 1
camera.lookAt new three.Vector3 0, 0, 0

renderer = new three.WebGLRenderer()
renderer.setSize 500, 500
renderer.domElement.style.position = 'absolute'
renderer.domElement.style.left = '0px'
renderer.domElement.style.top = '0px'

light = new three.DirectionalLight 0xffffff, 0.5
light.position.set 0.25, 0.5, 1
scene.add light

ambient = new three.AmbientLight 0x404040
scene.add ambient

document.body.appendChild renderer.domElement

# Origin for reference
originGeometry = new three.SphereGeometry 0.02 * SCALE, 32, 32
material = new three.MeshLambertMaterial color: 0xf0f0f0
origin = new three.Mesh originGeometry, material
scene.add origin

# Moving point's "shadow"
shadowGeometry = new three.SphereGeometry 0.02 * SCALE, 32, 32
material = new three.MeshLambertMaterial color: 0xf0f0f0
shadow = new three.Mesh shadowGeometry, material
scene.add shadow

# Moving point
pointGeometry = new three.SphereGeometry 0.02 * SCALE, 32, 32
material = new three.MeshLambertMaterial color: 0xf0f0f0
point = new three.Mesh pointGeometry, material
scene.add point

# Line from the origin to the "shadow"
lineMaterial = new three.LineBasicMaterial color: 0x00ff00
flatLineGeometry = new three.Geometry()
flatLineGeometry.vertices.push origin.position, shadow.position
flatLine = new three.Line flatLineGeometry, material
scene.add flatLine

vertLineGeometry = new three.Geometry()
vertLineGeometry.vertices.push shadow.position, point.position
vertLine = new three.Line vertLineGeometry, material
scene.add vertLine

point.position.x = point.position.y = point.position.z = 3


# Final things:
setPointLocation = (vector) ->
  point.position.x = vector.x
  point.position.y = vector.y
  point.position.z = vector.z

setScale = (scale) ->
  camera.position.x = camera.position.y = camera.position.z = scale

# CreateDetector returns a function that allows you to set the size of the visualized detector --
# use this to signify the strength of the signal received there
createDetector = (x, y, z) ->
  console.log x, y, z
  boxGeometry = new three.BoxGeometry 0.04 * SCALE, 0.04 * SCALE, 0.04 * SCALE
  material = new three.MeshLambertMaterial color: 0xf0f0f0
  detector = new three.Mesh boxGeometry, material
  detector.position.set x, y, z
  scene.add detector

  return {
    position: new three.Vector3 x, y, z
    setScale: (scale) ->
      detector.scale.set scale, scale, scale
  }


# Render loop
render = ->
  shadow.position.x = point.position.x
  shadow.position.y = point.position.y
  shadow.position.z = 0

  flatLine.geometry.verticesNeedUpdate = true
  vertLine.geometry.verticesNeedUpdate = true

  requestAnimationFrame render
  renderer.render scene, camera

do render

# APPLICATION

# Detector list -- fix
detectors = [
  createDetector(0, 6, 0)
  createDetector(0, -6, 0)
  createDetector(4, 0, 0)
  createDetector(-4, 0, 0)
]

# Example random visualization. Replace this with real estimation
setInterval (->
  setPointLocation(
    {
      x: point.position.x + (Math.random() / 10 - 1 / 20 ) * SCALE,
      y: point.position.y + (Math.random() / 10 - 1 / 20 ) * SCALE,
      z: point.position.z + (Math.random() / 10 - 1 / 20 ) * SCALE
    }
  )

  for detector in detectors
    detector.setScale SCALE / detector.position.distanceTo(point.position)

), 10
