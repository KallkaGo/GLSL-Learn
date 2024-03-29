import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import * as dat from 'lil-gui'
import testVertexShader from './shaders/vertex.glsl'
import vertexShader from './shaders/vertex.glsl'
// import viceVertex from './shaders/vice/vice_vertex.glsl'
// import viceFrag from './shaders/vice/vice_frag.glsl'


// import filmEffectFrag from './shaders/filmEffect.glsl'
// import testFragmentShader from './shaders/fragment.glsl'
// import fragmentShader from './shaders/fragment_1.glsl'
import fragmentShader from './shaders/disslove/dissolve.glsl'

import { FBXLoader } from 'three/examples/jsm/loaders/FBXLoader'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader'
import flowFrag from './shaders/flowmiss/flowmiss.glsl'

/**
 * Base
 */
// Debug
const gui = new dat.GUI()

const params = {
    clipFactor: 0,
    matcapIntensity: 4.84,
    matcapAddIntensity: 0.67,
    grow: -2,
    growMin: 0.524,
    growMax: 1.026,
    endMin: 0.63,
    endMax: 1.01,
    expand: -7.39,
    scale: 10

}



// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()



/* 
Loader
*/
const textureLoader = new THREE.TextureLoader()



const texture = textureLoader.load('bg2.png')

const texture2 = textureLoader.load('test.png')

const noise = textureLoader.load('noise.png')

/* Disslove */

const dissolveTex = textureLoader.load('/disslove/dissolveTex.png')

const RamTex = textureLoader.load('/disslove/dissolveRamp.png')


/* MatCap */
// const Matcap = textureLoader.load('/beetle/matcap_glass02.png')
// const MatcapAdd = textureLoader.load('/beetle/matcap_glass.png')
// const Diffuse = textureLoader.load('/beetle/beetle_diffuse.jpg')
// const RamTex = textureLoader.load('/beetle/ramp2.png')

// const bettleShaderMaterial = new THREE.ShaderMaterial({
//     vertexShader,
//     fragmentShader: filmEffectFrag,
//     uniforms: {
//         uMatcap: { value: Matcap },
//         uMatcapAdd:{value:MatcapAdd},
//         uDiffuse:{value:Diffuse},
//         uRamTex:{value:RamTex},
//         uMatcapIntensity: { value: params.matcapIntensity },
//         uMatcapAddIntensity:{value:params.matcapAddIntensity}
//     }
// })

// gui.add(params, 'matcapIntensity').min(0.1).max(5).step(0.01).onChange((value) => bettleShaderMaterial.uniforms.uMatcapIntensity.value = value)
// gui.add(params, 'matcapAddIntensity').min(0).max(5).step(0.01).onChange((value) => bettleShaderMaterial.uniforms.uMatcapAddIntensity.value = value)



// const fbxloader = new FBXLoader()
// fbxloader.load('./beetle/beetle.FBX', (model) => {
//     model.traverse((e) => {
//         if (e.type === 'Mesh' && Array.isArray(e.material)) {
//             for (let i = 0; i < e.material.length; i++) {
//                 e.material[i] = bettleShaderMaterial
//             }
//         }
//     })
//     model.scale.setScalar(0.01)
//     scene.add(model)
// })



// const Diffuse = textureLoader.load('/vice/Base_color.png')


// const viceShaderMaterial = new THREE.ShaderMaterial({
//     vertexShader: viceVertex,
//     fragmentShader: viceFrag,
//     side: THREE.DoubleSide,
//     uniforms: {
//         uDiffuse: { value: Diffuse },
//         uGrow: { value: params.grow },
//         uGrowMin: { value: params.growMin },
//         uGrowMax: { value: params.growMax },
//         uEndMin: { value: params.endMin },
//         uEndMax: { value: params.endMax },
//         uExpand: { value: params.expand },
//         uScale: { value: params.scale },
//     }
// })

// gui.add(params, "grow").min(-2).max(2).step(0.001)
//     .onChange((value) => viceShaderMaterial.uniforms.uGrow.value = value)
// gui.add(params, "growMin").min(0).max(1).step(0.001)
//     .onChange((value) => viceShaderMaterial.uniforms.uGrowMin.value = value)
// gui.add(params, "growMax").min(0).max(1.5).step(0.001)
//     .onChange((value) => viceShaderMaterial.uniforms.uGrowMax.value = value)
// gui.add(params, "endMin").min(0).max(1).step(0.01)
//     .onChange((value) => viceShaderMaterial.uniforms.uEndMin.value = value)
// gui.add(params, "endMax").min(0).max(1.5).step(0.01)
//     .onChange((value) => viceShaderMaterial.uniforms.uEndMax.value = value)
// gui.add(params, "expand").min(-20).max(20).step(0.001)
//     .onChange((value) => viceShaderMaterial.uniforms.uExpand.value = value)
// gui.add(params, "scale").min(-10).max(10).step(0.001)
//     .onChange((value) => viceShaderMaterial.uniforms.uScale.value = value)


// const fbxloader = new FBXLoader()
// fbxloader.load('./vice/vine2_ci3.FBX', (model) => {

//     model.traverse((e) => {
//         console.log('@', e)
//         if (e.type === 'Mesh') {
//             e.material = viceShaderMaterial
//         }
//     })
//     model.scale.setScalar(0.5)
//     scene.add(model)
// })

// const shaderMaterial = new THREE.ShaderMaterial({
//     vertexShader,
//     fragmentShader: flowFrag,
//     uniforms: {
//         uTex: { value: noise },
//         uTime: { value: 0 }
//     },
//     transparent: true,
//     blending: THREE.AdditiveBlending
// })




/* Light */

const ambientlight = new THREE.AmbientLight('gray', 0.1)
scene.add(ambientlight)

/**
 * Test mesh
 */
// Geometry
const geometry = new THREE.PlaneGeometry(2, 2, 32, 32)

const iResolution = new THREE.Vector3(innerWidth, innerHeight, innerWidth / innerHeight)


// Material
const material = new THREE.ShaderMaterial({
    vertexShader: vertexShader,
    fragmentShader: fragmentShader,
    // side: THREE.DoubleSide,
    uniforms: {
        uTime: { value: 0 },
        iTime: { value: 0 },
        iResolution: { value: iResolution },
        iChannel0: { value: null },
        iChannel1: { value: noise },
        iDissloveTex: { value: dissolveTex },
        iClip: { value: 0 },
        iRamTex: { value: RamTex }
    },
    // transparent: true,
    // depthWrite: false
    transparent: true,
    blending: THREE.AdditiveBlending
})

gui.add(params, 'clipFactor').min(0).max(1).step(0.01).name('溶解因子').onChange(() => {
    material.uniforms.iClip.value = params.clipFactor
})

const gltfloader = new GLTFLoader()
gltfloader.load('model.glb', (model) => {
    model.scene.traverse((e) => {

        if (e.type === 'Mesh') {
            e.material = material
        }
    })
    model.scene.scale.setScalar(0.01)
    scene.add(model.scene)
})



// const sphereGeometry = new THREE.SphereGeometry(1)

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
    canvas: canvas,
    antialias: true
})
// renderer.autoClear = false
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
// renderer.setClearColor('ivory')

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