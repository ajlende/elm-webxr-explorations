const _elm_community$webgl$Native_AnimationFrame = (() => {
    const frame = F2((time, pose) => ({ ctor: "Frame", time, pose }))

    const getTime = ({ time }) => time

    const getPose = ({ pose }) => pose

    const createRAFSub = () =>
        _elm_lang$core$Native_Scheduler.nativeBinding(callback => {
            // prettier-ignore
            const identity = [
                1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0
            ]

            const onXRFrame = (time = Date.now(), pose = identity) => {
                const result = A2(frame, time, pose)
                const task = _elm_lang$core$Native_Scheduler.succeed(result)
                callback(task)
            }

            const id = requestAnimationFrame(onXRFrame)

            return () => cancelAnimationFrame(id)
        })

    return { createRAFSub, frame, getTime, getPose }
})()
