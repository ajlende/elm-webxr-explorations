var _elm_community$webgl$Native_AnimationFrame = (() => {
    // TODO: Get identity directly from linear-algebra so nothing breaks if the
    // implementation changes.

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

    const setTime = (time, { frame }) => A2(createFrame, time, frame)

    const getPose = F2(({ frameOfRef }, { frame }) =>
        frame.getDevicePose(frameOfRef)
    )

    const createRAFSub = session =>
        _elm_lang$core$Native_Scheduler.nativeBinding(callback => {
            const onXRFrame = (time = Date.now(), frame = null) => {
                const frameOfReference = getXRFrameOfReferenceSomehow()
                const result = A4(
                    createFrame,
                    time,
                    frame,
                    session,
                    frameOfReference
                )
                const task = _elm_lang$core$Native_Scheduler.succeed(result)
                callback(task)
            }

            const id = session.requestAnimationFrame(onXRFrame)

            return () => session.cancelAnimationFrame(id)
        })

    return { createRAFSub, createFrame, getTime, setTime, getPose }
})()
