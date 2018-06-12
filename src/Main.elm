module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (height, width)
import Html.Events exposing (onClick)
import Task
import WebGL exposing (clearColor, xrContext)
import WebXR.AnimationFrame exposing (Frame, getPose, getTime, times)
import WebXR.Context exposing (Context, Error, context)


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
    { frame : Maybe Frame
    , context : Maybe Context
    }



-- INIT


init : () -> ( Model, Cmd Msg )
init flags =
    ( { frame = Nothing
      , context = Nothing
      }
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.context of
        Just context ->
            times (Animate context)

        Nothing ->
            Sub.none



-- UPDATE


type Msg
    = NoOp
    | EnterXR
    | XRUpgrade (Result Error Context)
    | Animate Context Frame


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        EnterXR ->
            ( model
            , Task.attempt XRUpgrade (WebXR.Context.upgrade context [])
            )

        XRUpgrade context ->
            ( { model | context = Result.toMaybe context }, Cmd.none )

        Animate _ frame ->
            ( { model | frame = Just frame }, Cmd.none )



-- VIEW


webGLOptions : Model -> List WebGL.Option
webGLOptions model =
    case ( model.context, model.frame ) of
        ( Just context, Just frame ) ->
            [ clearColor 1.0 0.0 0.0 1.0
            , xrContext context
            ]

        ( _, _ ) ->
            [ clearColor 0.027 0.216 0.275 1.0
            , xrContext context
            ]


info : Model -> Html Msg
info model =
    case ( model.context, model.frame ) of
        ( Just context, Just frame ) ->
            div []
                [ div []
                    [ text ("Time: " ++ (frame |> getTime |> toString))
                    ]
                , div []
                    [ text ("Pose: " ++ (frame |> getPose |> toString))
                    ]
                ]

        ( _, _ ) ->
            div []
                [ text "Loading..."
                ]


view : Model -> Html Msg
view model =
    div [ onClick EnterXR ]
        [ WebGL.toHtmlWith
            (webGLOptions model)
            [ width 588
            , height 388
            ]
            []
        , info model
        ]
