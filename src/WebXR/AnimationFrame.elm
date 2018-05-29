effect module WebXR.AnimationFrame
    where { subscription = MySub }
    exposing
        ( Frame
        , diffs
        , frame
        , getPose
        , getTime
        , times
        )

{-| WebXR has a special requestAnimationFrame function that includes a
timestamp and an [XRPresentationFrame]. For now, I'm just exposing the Pose as
a [Mat4] from [elm-community/linear-algebra].

[XRPresentationFrame]: https://immersive-web.github.io/webxr/#xrpresentationframe-interface
[Mat4]: http://package.elm-lang.org/packages/elm-community/linear-algebra/3.1.2/Math-Matrix4#Mat4
[elm-community/linear-algebra]: http://package.elm-lang.org/packages/elm-community/linear-algebra/latest


# Animation Subscriptions

@docs times, diffs

-}

import Math.Matrix4 as Matrix4 exposing (Mat4)
import Native.AnimationFrame
import Process
import Task exposing (Task)
import Time exposing (Time)


type Frame
    = Frame


frame : Time -> Mat4 -> Frame
frame =
    Native.AnimationFrame.frame


getPose : Frame -> Mat4
getPose =
    Native.AnimationFrame.getPose


getTime : Frame -> Time
getTime =
    Native.AnimationFrame.getTime


{-| Subscribe to the current time, given in lockstep with the browser's natural
rerender speed.
-}
times : (Frame -> msg) -> Sub msg
times tagger =
    subscription (Time tagger)


{-| Subscribe to the time diffs between animation frames, given in lockstep
with the browser's natural rerender speed.
-}
diffs : (Frame -> msg) -> Sub msg
diffs tagger =
    subscription (Diff tagger)



-- SUBSCRIPTIONS


type MySub msg
    = Time (Frame -> msg)
    | Diff (Frame -> msg)


subMap : (a -> b) -> MySub a -> MySub b
subMap func sub =
    case sub of
        Time tagger ->
            Time (tagger >> func)

        Diff tagger ->
            Diff (tagger >> func)



-- EFFECT MANAGER


type alias State msg =
    { subs : List (MySub msg)
    , request : Maybe Process.Id
    , oldFrame : Frame
    }


init : Task Never (State msg)
init =
    Task.succeed (State [] Nothing Frame)


onEffects : Platform.Router msg Frame -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router subs { request, oldFrame } =
    case ( request, subs ) of
        ( Nothing, [] ) ->
            Task.succeed (State [] Nothing oldFrame)

        ( Just pid, [] ) ->
            Process.kill pid
                |> Task.andThen (\_ -> Task.succeed (State [] Nothing oldFrame))

        ( Nothing, _ ) ->
            Process.spawn (Task.andThen (Platform.sendToSelf router) rAF)
                |> Task.andThen (\pid -> Task.succeed (State subs (Just pid) oldFrame))

        ( Just _, _ ) ->
            Task.succeed (State subs request oldFrame)


onSelfMsg : Platform.Router msg Frame -> Frame -> State msg -> Task Never (State msg)
onSelfMsg router newFrame { subs, oldFrame } =
    let
        newPose =
            getPose newFrame

        newTime =
            getTime newFrame

        oldTime =
            getTime oldFrame

        diffFrame =
            frame (newTime - oldTime) newPose

        send sub =
            case sub of
                Time tagger ->
                    Platform.sendToApp router (tagger newFrame)

                Diff tagger ->
                    Platform.sendToApp router (tagger diffFrame)
    in
    Process.spawn (Task.andThen (Platform.sendToSelf router) rAF)
        |> Task.andThen
            (\pid ->
                Task.sequence (List.map send subs)
                    |> Task.andThen (\_ -> Task.succeed (State subs (Just pid) newFrame))
            )


rAF : Task x Frame
rAF =
    Native.AnimationFrame.createRAFSub ()
