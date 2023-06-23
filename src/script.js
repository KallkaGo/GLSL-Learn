import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import * as dat from 'lil-gui'
import testVertexShader from './shaders/vertex.glsl'
import vertexShader from './shaders/vertex.glsl'
import filmEffectFrag from './shaders/filmEffect.glsl'
import testFragmentShader from './shaders/fragment.glsl'
// import fragmentShader from './shaders/fragment_1.glsl'
import fragmentShader from './shaders/dissolve.glsl'

import { FBXLoader } from 'three/examples/jsm/loaders/FBXLoader'
import flowFragmen from './shaders/flowmiss.glsl'

/**
 * Base
 */
// Debug
const gui = new dat.GUI()

const params = {
    clipFactor: 0,
    matcapIntensity: 4.84,
    matcapAddIntensity:0.67
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

// const texture2 = textureLoader.load('test.png')

// const noise = textureLoader.load('noise.png')

// const dissolveTex = textureLoader.load('dissolveTex.png')

// const RamTex = textureLoader.load('dissolveRamp.png')

const Matcap = textureLoader.load('/beetle/matcap_glass02.png')
const MatcapAdd = textureLoader.load('/beetle/matcap_glass.png')
const Diffuse = textureLoader.load('/beetle/beetle_diffuse.jpg')
const RamTex = textureLoader.load('/beetle/ramp2.png')

const bettleShaderMaterial = new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader: filmEffectFrag,
    uniforms: {
        uMatcap: { value: Matcap },
        uMatcapAdd:{value:MatcapAdd},
        uDiffuse:{value:Diffuse},
        uRamTex:{value:RamTex},
        uMatcapIntensity: { value: params.matcapIntensity },
        uMatcapAddIntensity:{value:params.matcapAddIntensity}
    }
})

gui.add(params, 'matcapIntensity').min(0.1).max(5).step(0.01).onChange((value) => bettleShaderMaterial.uniforms.uMatcapIntensity.value = value)
gui.add(params, 'matcapAddIntensity').min(0).max(5).step(0.01).onChange((value) => bettleShaderMaterial.uniforms.uMatcapAddIntensity.value = value)



const fbxloader = new FBXLoader()
fbxloader.load('./beetle/beetle.FBX', (model) => {
    model.traverse((e) => {
        if (e.type === 'Mesh' && Array.isArray(e.material)) {
            for (let i = 0; i < e.material.length; i++) {
                e.material[i] = bettleShaderMaterial
            }
        }
    })
    console.log(model)
    model.name = 'beetle'
    model.scale.setScalar(0.01)
    scene.add(model)
})


// const directionLight = new THREE.DirectionalLight('white', 0.1)
// directionLight.position.set(6, 4, 5)
// scene.add(directionLight)


const ambientlight = new THREE.AmbientLight('gray', 0.1)
scene.add(ambientlight)

/**
 * Test mesh
 */
// Geometry
const geometry = new THREE.PlaneGeometry(2, 2, 32, 32)

const iResolution = new THREE.Vector3(innerWidth, innerHeight, innerWidth / innerHeight)


// Material
// const material = new THREE.ShaderMaterial({
//     vertexShader: testVertexShader,
//     fragmentShader: fragmentShader,
//     side: THREE.DoubleSide,
//     uniforms: {
//         uTime: { value: 0 },
//         iTime: { value: 0 },
//         iResolution: { value: iResolution },
//         iChannel0: { value: null },
//         iChannel1: { value: texture2 },
//         iDissloveTex: { value: dissolveTex },
//         iClip: { value: 0 },
//         iRamTex: { value: RamTex }
//     },
//     transparent: true,
//     depthWrite: false
// })

// gui.add(params, 'clipFactor').min(0).max(1).step(0.01).name('溶解因子').onChange(() => {
//     material.uniforms.iClip.value = params.clipFactor
// })

const shaderMaterial = new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader: flowFragmen,
    uniforms: {
        uTex: { value: null },
        uTime: { value: 0 }
    },
    transparent: true,
    blending: THREE.AdditiveBlending
})


const sphereGeometry = new THREE.SphereGeometry(1)

// Mesh
// const mesh = new THREE.Mesh(geometry, material)

// const cube = new THREE.Mesh(sphereGeometry, shaderMaterial)

// mesh.position.set(0, 0, -2)

// cube.position.set(0, 0, 0.2)

// scene.add(mesh)

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
    // material.uniforms.uTime.value = elapsedTime
    // material.uniforms.iTime.value = elapsedTime

    // shaderMaterial.uniforms.uTime.value = elapsedTime

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()