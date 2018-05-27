module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)



-- MAIN


main : Program () Model Msg
main =
    Browser.fullscreen
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onNavigation = Nothing
        }



-- MODEL


type alias Model =
    { count : Int
    }



-- INIT


init : Browser.Env () -> ( Model, Cmd Msg )
init env =
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


view : Model -> Browser.Page Msg
view model =
    { title = "Elm WebXR Example"
    , body =
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (String.fromInt model.count) ]
        , button [ onClick Increment ] [ text "+" ]
        ]
    }
