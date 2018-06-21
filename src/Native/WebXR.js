var _elm_community$webgl$Native_WebXR = (() => {
    const LOG = console.log.bind(console, "WebXR")
    // const LOG = (...args) => document.write(args.reduce((x, a) => `${x} ${a}<br>`, "WebXR:"))

    const cache = {}

    /**
     * A context for passing around "globals" needed for WebXR
     * @private
     * @param {XRDevice} device XRDevice for the page
     * @param {XRSession} session XRSession for the page
     * @param {XRFrameOfReference} frameOfRef XRFrameOfReference for the page
     */
    const createContext = (device, session, frameOfRef) => ({
        ctor: "Context",
        device,
        session,
        frameOfRef,
        requestWebGL: () =>
            new Promise((resolve, reject) => {
                let count = 0
                let timer
                // 😧 🤷‍♂ 🔥
                const getGlobalXRContext = () => {
                    count++
                    if (count > 10) {
                        reject(new Error("Context is missing"))
                        window.clearInterval(timer)
                    }
                    if (window._elm_community$webgl$Native_WebXR$context) {
                        resolve(
                            window._elm_community$webgl$Native_WebXR$context
                        )
                        window.clearInterval(timer)
                    }
                }
                timer = setInterval(getGlobalXRContext, 1000)
            })
    })

    const upgrade = (context, options) =>
        _elm_lang$core$Native_Scheduler.nativeBinding(async callback => {
            // Default XR options
            let exclusive = true
            let frameOfReferenceType = "eyeLevel"

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

                LOG("request XRDevice")
                const device = await navigator.xr.requestDevice()
                cache.device = device
                LOG("XRDevice created")

                LOG("check XRSession")
                await device
                    .supportsSession({ exclusive })
                    .catch(() => (exclusive = false))
                if (!exclusive) LOG("Warning: NotExclusiveSession")

                LOG("request XRSession")
                const session = await device.requestSession({
                    exclusive
                })
                cache.session = session
                LOG("XRSession created")

                LOG(`request "${frameOfReferenceType}" XRFrameOfReference`)
                const frameOfRef = await session.requestFrameOfReference(
                    frameOfReferenceType
                )
                cache.frameOfRef = frameOfRef
                LOG("XRFrameOfRef created")

                LOG("request WebGL context")
                const gl = await context.requestWebGL()
                LOG("WebGL context acquired")

                LOG("try setCompatibleXRDevice")
                await gl.setCompatibleXRDevice(device)
                LOG("XRDevice attached")

                LOG("create baseLayer XRWebGLLayer ")
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
