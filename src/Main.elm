module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (height, width)
import Html.Events exposing (onClick)
import WebGL exposing (clearColor)


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
    { count : Int
    }



-- INIT


init : () -> ( Model, Cmd Msg )
init flags =
    ( { count = 0
      }
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | count = model.count + 1 }, Cmd.none )

        Decrement ->
            ( { model | count = model.count - 1 }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (toString model.count) ]
        , button [ onClick Increment ] [ text "+" ]
        , WebGL.toHtmlWith
            [ clearColor 0.027 0.216 0.275 1.0
            ]
            [ width 500
            , height 500
            ]
            []
        ]
