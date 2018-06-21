var _elm_community$webgl$Native_AnimationFrame = (() => {
    // TODO: Get identity directly from linear-algebra so nothing breaks if the
    // implementation changes.
    let xrContextCache = {}

    // prettier-ignore
    const identity = [
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    ]

    const createFrame = F2((time, frame) => ({
        ctor: "Frame",
        time,
        frame
    }))

    const getTime = ({ time }) => time

    const setTime = F2((time, { frame }) => A2(createFrame, time, frame))

    const getPose = ({ frame }) =>
        frame.getDevicePose(xrContextCache.frameOfRef)

    const createRAFSub = ({ cache }) => {
        xrContextCache = cache
        return _elm_lang$core$Native_Scheduler.nativeBinding(callback => {
            const onXRFrame = (time = Date.now(), frame = null) => {
                const result = A2(createFrame, time, frame)
                const task = _elm_lang$core$Native_Scheduler.succeed(result)
                callback(task)
            }

            const id = xrContextCache.session.requestAnimationFrame(onXRFrame)

            return () => xrContextCache.session.cancelAnimationFrame(id)
        })
    }

    return { createRAFSub, createFrame, getTime, setTime, getPose }
})()
