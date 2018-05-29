module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (height, width)
import Math.Matrix4 as Matrix4 exposing (Mat4)
import WebGL exposing (clearColor)
import WebXR.AnimationFrame exposing (Frame, frame, getPose, getTime, times)


-- MAIN


main : Program () Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { frame : Frame
    }



-- INIT


init : () -> ( Model, Cmd Msg )
init flags =
    ( { frame = frame 0 Matrix4.identity }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    times Animate



-- UPDATE


type Msg
    = NoOp
    | Animate Frame


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Animate frame ->
            ( { model | frame = frame }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ WebGL.toHtmlWith
            [ clearColor 0.027 0.216 0.275 1.0
            ]
            [ width 500
            , height 500
            ]
            []
        , div []
            [ text ("Time: " ++ (model.frame |> getTime |> toString))
            ]
        , div []
            [ text ("Pose: " ++ (model.frame |> getPose |> toString))
            ]
        ]
