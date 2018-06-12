effect module WebXR.AnimationFrame
    where { subscription = AFSub }
    exposing
        ( Frame
        , diffs
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
import WebXR.Context exposing (Context, context)


type Frame
    = Frame


getPose : Frame -> Mat4
getPose =
    Native.AnimationFrame.getPose


getTime : Frame -> Time
getTime =
    Native.AnimationFrame.getTime


setTime : Time -> Frame -> Frame
setTime =
    Native.AnimationFrame.setTime


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


type AFSub msg
    = Time (Frame -> msg)
    | Diff (Frame -> msg)


subMap : (a -> b) -> AFSub a -> AFSub b
subMap func sub =
    case sub of
        Time tagger ->
            Time (tagger >> func)

        Diff tagger ->
            Diff (tagger >> func)



-- EFFECT MANAGER


type alias State msg =
    { subs : List (AFSub msg)
    , request : Maybe Process.Id
    , context : Context
    , oldFrame : Frame
    }


init : Task Never (State msg)
init =
    Task.succeed (State [] Nothing context Frame)


onEffects : Platform.Router msg Frame -> List (AFSub msg) -> State msg -> Task Never (State msg)
onEffects router subs { request, context, oldFrame } =
    case ( request, subs ) of
        ( Nothing, [] ) ->
            Task.succeed (State [] Nothing context oldFrame)

        ( Just pid, [] ) ->
            Process.kill pid
                |> Task.andThen (\_ -> Task.succeed (State [] Nothing context oldFrame))

        ( Nothing, _ ) ->
            Process.spawn (Task.andThen (Platform.sendToSelf router) (rAF context))
                |> Task.andThen (\pid -> Task.succeed (State subs (Just pid) context oldFrame))

        ( Just _, _ ) ->
            Task.succeed (State subs request context oldFrame)


onSelfMsg : Platform.Router msg Frame -> Frame -> State msg -> Task Never (State msg)
onSelfMsg router newFrame { subs, oldFrame, context } =
    let
        diffFrame =
            setTime (getTime newFrame - getTime oldFrame) newFrame

        send sub =
            case sub of
                Time tagger ->
                    Platform.sendToApp router (tagger newFrame)

                Diff tagger ->
                    Platform.sendToApp router (tagger diffFrame)
    in
    Process.spawn (Task.andThen (Platform.sendToSelf router) (rAF context))
        |> Task.andThen
            (\pid ->
                Task.sequence (List.map send subs)
                    |> Task.andThen (\_ -> Task.succeed (State subs (Just pid) context newFrame))
            )


rAF : Context -> Task x Frame
rAF context =
    Native.AnimationFrame.createRAFSub context
