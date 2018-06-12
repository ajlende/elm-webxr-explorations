module WebXR.Context exposing (Context, Error, context, upgrade)

import Native.WebXR
import Task exposing (Task)
import WebXR exposing (XROption)


type Context
    = Context


context : Context
context =
    Native.WebXR.context


type Error
    = UnknownError String


upgrade : Context -> List XROption -> Task Error Context
upgrade =
    Native.WebXR.upgrade
