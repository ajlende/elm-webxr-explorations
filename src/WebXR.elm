module WebXR
    exposing
        ( FrameOfReference
        , XROption
        , exclusiveSession
        , eyeLevel
        , frameOfReference
        , headModel
        , stage
        )

{-| For creating virtual reality and augmented reality experiences in Elm.
-}


{-| Different ways the XR space can be framed

[Official Docs](https://immersive-web.github.io/webxr/#xrframeofreference-interface)

-}
type FrameOfReference
    = HeadModel
    | EyeLevel
    | Stage


{-| TODO

[Official Docs](https://immersive-web.github.io/webxr/#xrframeofreference-interface)

-}
headModel : FrameOfReference
headModel =
    HeadModel


{-| All poses will be relative to the location where the XRDevice was first
detected

[Official Docs](https://immersive-web.github.io/webxr/#xrframeofreference-interface)

-}
eyeLevel : FrameOfReference
eyeLevel =
    EyeLevel


{-| TODO

[Official Docs](https://immersive-web.github.io/webxr/#xrframeofreference-interface)

-}
stage : FrameOfReference
stage =
    Stage


{-| Options that can be supplied when upgrading a webGL context to webXR
-}
type XROption
    = CoordinateSystem FrameOfReference
    | Exclusive Bool


{-| Creates a FremeOfReferenceType XROption which is required for querying poses

[Official Docs](https://immersive-web.github.io/webxr/#xrframeofreference-interface)

-}
frameOfReference : FrameOfReference -> XROption
frameOfReference =
    CoordinateSystem


{-| TODO: This also wasn't documented very well

[Official Docs](https://immersive-web.github.io/webxr/#issue-71eaf0cc)

-}
exclusiveSession : Bool -> XROption
exclusiveSession =
    Exclusive
