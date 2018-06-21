var _elm_community$webgl$Native_WebXR = (() => {
    const LOG = console.log.bind(console, "WebXR")
    // const LOG = (...args) => document.write(args.reduce((x, a) => `${x} ${a}<br>`, "WebXR:"))

    const cache = {}

    const enterXRAction = {
        ctor: "EnterXRExclusive"
    }

    /**
     * A context for passing around "globals" needed for WebXR
     * @private
     * @param {XRDevice} device XRDevice for the page
     * @param {XRSession} session XRSession for the page
     * @param {XRFrameOfReference} frameOfRef XRFrameOfReference for the page
     */
    const createContext = (device, session, frameOfRef) => ({
        ctor: "Context",
        cache,
        requestWebGL: () =>
            new Promise((resolve, reject) => {
                let count = 0
                let timer
                // 😧 🤷‍♂ 🔥
                const getGlobalGLContext = () => {
                    count++
                    if (count > 10) {
                        reject(new Error("Context is missing"))
                        window.clearInterval(timer)
                    }
                    if (window._elm_community$webgl$Native_WebXR$gl) {
                        resolve(
                            window._elm_community$webgl$Native_WebXR$gl
                        )
                        window.clearInterval(timer)
                    }
                }
                timer = setInterval(getGlobalGLContext, 1000)
            })
    })

    const upgrade = (context, options) =>
        _elm_lang$core$Native_Scheduler.nativeBinding(async callback => {
            // Default XR options
            let exclusive = false
            let frameOfReferenceType = "eye-level"

            _elm_lang$core$Native_List.toArray(options).forEach(option => {
                switch (option.ctor) {
                    case "FrameOfRef":
                        switch (option._0.ctor) {
                            case "HeadModel":
                                xrSettings.frameOfReferenceType = "head-model"
                                break
                            case "EyeLevel":
                                xrSettings.frameOfReferenceType = "eye-level"
                                break
                            case "Stage":
                                xrSettings.frameOfReferenceType = "stage"
                                break
                        }
                        break
                    case "Exclusive":
                        xrSettings.exclusive = option._0
                        break
                }
            })

            try {
                if (!navigator.xr) throw new Error("WebXR not supported")
                LOG("XR supported")

                const outputCanvas = document.createElement("canvas")
                const outputContext = outputCanvas.getContext("xrpresent")
                document.body.appendChild(outputCanvas)
                LOG("XR mirror canvas created")

                const gl = await context.requestWebGL()
                LOG("WebGL context acquired")

                const device = await navigator.xr.requestDevice()
                cache.device = device
                LOG("XRDevice created")

                await gl.setCompatibleXRDevice(device)
                LOG("XRDevice attached")

                await device.supportsSession({ exclusive, outputContext })
                if (!exclusive) LOG("Warning: NotExclusiveSession")
                LOG("XRSession supported")

                const session = await device.requestSession({
                    exclusive,
                    outputContext
                })
                cache.session = session
                LOG("XRSession created")

                const frameOfRef = await session.requestFrameOfReference(
                    frameOfReferenceType
                )
                cache.frameOfRef = frameOfRef
                LOG("XRFrameOfRef created")

                session.baseLayer = new XRWebGLLayer(session, gl)
                LOG("XRWebGLLayer created")

                const value = _elm_lang$core$Native_Utils.Tuple0
                const task = _elm_lang$core$Native_Scheduler.succeed(value)
                callback(task)
            } catch (err) {
                LOG("XR Error", err)
                const error = { ctor: "UnknownError", _0: `${err}` }
                const task = _elm_lang$core$Native_Scheduler.fail(error)
                callback(task)
            }
        })

    return { upgrade: F2(upgrade), context: createContext() }
})()
