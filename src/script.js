import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import * as dat from 'lil-gui'
import testVertexShader from './shaders/vertex.glsl'
import vertexShader from './shaders/vertex.glsl'
import testFragmentShader from './shaders/fragment.glsl'
// import fragmentShader from './shaders/fragment_1.glsl'
import fragmentShader from './shaders/dissolve.glsl'

import flowFragmen from './shaders/flowmiss.glsl'

/**
 * Base
 */
// Debug
const gui = new dat.GUI()

const params ={
    clipFactor:0
}



// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()



const worldSpcaeCameraPos = new THREE.Vector3()

/* 
Loader
*/
const textureLoader = new THREE.TextureLoader()

// const texture = textureLoader.load('bg2.png')

const texture2 = textureLoader.load('test.png')

// const noise = textureLoader.load('noise.png')

const dissolveTex = textureLoader.load('dissolveTex.png')

const RamTex = textureLoader.load('dissolveRamp.png')


/**
 * Test mesh
 */
// Geometry
const geometry = new THREE.PlaneGeometry(2, 2, 32, 32)

const iResolution = new THREE.Vector3(innerWidth, innerHeight, innerWidth / innerHeight)


// Material
const material = new THREE.ShaderMaterial({
    vertexShader: testVertexShader,
    fragmentShader: fragmentShader,
    side: THREE.DoubleSide,
    uniforms: {
        uTime: { value: 0 },
        iTime: { value: 0 },
        iResolution: { value: iResolution },
        iChannel0: { value: null },
        iChannel1: { value: texture2 },
        iDissloveTex:{value:dissolveTex},
        iClip:{value:0},
        iRamTex:{value:RamTex}
    },
    transparent: true,
    depthWrite: false
})

gui.add(params,'clipFactor').min(0).max(1).step(0.01).name('溶解因子').onChange(()=>{
    material.uniforms.iClip.value = params.clipFactor
})

const shaderMaterial = new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader: flowFragmen,
    uniforms: {
        uTex:{value:null},
        uTime:{value:0}
    },
    transparent: true,
    blending: THREE.AdditiveBlending
})


const sphereGeometry = new THREE.SphereGeometry(1)

// Mesh
const mesh = new THREE.Mesh(geometry, material)

const cube = new THREE.Mesh(sphereGeometry, shaderMaterial)

mesh.position.set(0, 0, -2)

cube.position.set(0, 0, 0.2)

scene.add(mesh)

/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

window.addEventListener('resize', () => {
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100)
camera.position.set(0.25, - 0.25, 3)
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas
})
// renderer.autoClear = false
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
renderer.setClearColor('ivory')

/**
 * Animate
 */
const clock = new THREE.Clock()

const tick = () => {
    const elapsedTime = clock.getElapsedTime()

    // Update controls
    controls.update()

    // Update uTime
    material.uniforms.uTime.value = elapsedTime
    material.uniforms.iTime.value = elapsedTime

    shaderMaterial.uniforms.uTime.value = elapsedTime

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()