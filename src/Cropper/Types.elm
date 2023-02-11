module Cropper.Types exposing
    ( CropData
    , Drag
    , Image
    , ImageData
    , Model
    , Msg(..)
    , Point
    , Position
    , Rect
    , Rectangle
    , Vector
    , decodeImage
    )

{-| Types

# Types

@docs CropData, Drag, Image, ImageData, Model
@docs Msg(..)
@docs Point, Position, Rect
@docs Rectangle, Vector, decodeImage

-}

import Browser.Dom
import Browser.Events exposing (..)
import DOM
import Html.Events.Extra.Touch exposing (Touch)
import Json.Decode exposing (Decoder)


{-| grectangle
-}
type alias Rectangle =
    DOM.Rectangle


{-| pozition
-}
type alias Position =
    { x : Int
    , y : Int
    }


{-| filling out these docs is a drag
-}
type alias Drag =
    { start : Position
    , current : Position
    }


{-| the REAL message type....(wow)
-}
type Msg
    = ImageLoaded Image
    | Measure DOM.Rectangle
    | Zoom Float
    | DragStart Position
    | DragAt Position
    | DragEnd Position
    | OnTouchStart ( Float, Float )
    | OnTouchMove ( Float, Float )
    | OnTouchEnd ( Float, Float )


{-| mobel
-}
type alias Model =
    { url : String
    , crop : Rect
    , image : Maybe Image
    , boundingClientRect : Rectangle
    , pivot : Vector
    , zoom : Float
    , drag : Maybe Drag
    }


{-| vegtor
-}
type alias Vector =
    { x : Float
    , y : Float
    }


{-| Rectangle..... TWO!!!!!!!!
-}
type alias Rect =
    { width : Int
    , height : Int
    }


{-| image object
-}
type alias Image =
    { src : String
    , width : Int
    , height : Int
    }


{-| decode image object
-}
decodeImage : Json.Decode.Decoder Image
decodeImage =
    Json.Decode.map3 Image
        (Json.Decode.at [ "target", "src" ] Json.Decode.string)
        (Json.Decode.at [ "target", "width" ] Json.Decode.int)
        (Json.Decode.at [ "target", "height" ] Json.Decode.int)


{-| point. x, y, all that business
-}
type alias Point =
    { x : Int
    , y : Int
    }


{-| image data
-}
type alias ImageData =
    { url : String
    , crop : Rect
    }


{-| crop data
-}
type alias CropData =
    { url : String
    , size : Rect
    , crop : Rect
    , resized : Rect
    , origin : Point
    }
