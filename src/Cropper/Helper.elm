module Cropper.Helper exposing (..)

import Cropper.Types as Types exposing (..)

zoomImage : Model -> Float -> Model
zoomImage model zoom =
    { model | zoom = Basics.clamp 0.0 1.0 zoom }


pivotXY : Model -> { x : Float, y : Float } -> Model
pivotXY model pivot =
    let
        c =
            { x = Basics.clamp 0.0 1.0 pivot.x
            , y = Basics.clamp 0.0 1.0 pivot.y
            }
    in
        { model | pivot = c }


pivotX : Model -> Float -> Model
pivotX model x =
    pivotXY model { x = x, y = model.pivot.y }


pivotY : Model -> Float -> Model
pivotY model y =
    pivotXY model { x = model.pivot.x, y = y }


cropImage : Model -> { width : Int, height : Int } -> Model
cropImage model crop =
    case model.image of
        Nothing ->
            model

        Just image ->
            { model | crop = limitCrop crop image }


limitCrop : Rect -> Image -> Rect
limitCrop crop image =
    if image.width >= crop.width && image.height >= crop.height then
        crop
    else
        Rect image.width image.height


dragDistance : Maybe Drag -> Position
dragDistance drag =
    case drag of
        Just drag_ ->
            Position (drag_.start.x - drag_.current.x) (drag_.start.y - drag_.current.y)

        Nothing ->
            Position 0 0


getPivot : Model -> Vector
getPivot model =
    case model.image of
        Nothing ->
            model.pivot

        Just image ->
            case model.drag of
                Nothing ->
                    model.pivot

                Just { start, current } ->
                    let
                        currentSize =
                            imageSize
                                { image = image
                                , crop = model.crop
                                , zoom = model.zoom
                                }

                        currentHeight =
                            currentSize.y

                        currentWidth =
                            currentSize.x

                        rangeX =
                            (toFloat model.crop.width / (currentWidth - toFloat model.crop.width))

                        rangeY =
                            (toFloat model.crop.height / (currentHeight - toFloat model.crop.height))

                        distance =
                            dragDistance model.drag

                        pivotX_ =
                            (toFloat distance.x / model.boundingClientRect.width) * rangeX

                        pivotY_ =
                            (toFloat distance.y / model.boundingClientRect.height) * rangeY

                        dragPivot =
                            Vector pivotX_ pivotY_
                    in
                        (pivotXY model { x = (model.pivot.x + dragPivot.x), y = (model.pivot.y + dragPivot.y) }).pivot


imageRatio : { a | image : Image, crop : Rect } -> Vector
imageRatio { image, crop } =
    Vector
        (toFloat image.width / toFloat crop.width)
        (toFloat image.height / toFloat crop.height)


imageSize : { a | image : Image, crop : Rect, zoom : Float } -> Vector
imageSize { image, crop, zoom } =
    let
        ratio =
            imageRatio { crop = crop, image = image }

        ratioMin =
            Basics.min ratio.x ratio.y

        minWidth =
            toFloat crop.width * (ratio.x / ratioMin)

        minHeight =
            toFloat crop.height * (ratio.y / ratioMin)

        width =
            minWidth + ((toFloat image.width - minWidth) * zoom)

        height =
            minHeight + ((toFloat image.height - minHeight) * zoom)
    in
        Vector width height


cropOrigin : { a | image : Image, pivot : Vector, crop : Rect, zoom : Float } -> Vector
cropOrigin { crop, pivot, zoom, image } =
    let
        size =
            imageSize { image = image, crop = crop, zoom = zoom }

        x =
            pivot.x * (size.x - toFloat crop.width)

        y =
            pivot.y * (size.y - toFloat crop.height)
    in
        Vector x y


cropData : Model -> CropData
cropData model =
    case (model.image) of
        Nothing ->
            { url = model.url
            , size = Rect 0 0
            , crop = model.crop
            , resized = Rect 0 0
            , origin = Point 0 0
            }

        Just image ->
            let
                size =
                    imageSize { crop = model.crop, zoom = model.zoom, image = image }

                origin =
                    cropOrigin { crop = model.crop, pivot = model.pivot, zoom = model.zoom, image = image }
            in
                { url = image.src
                , size =
                    { width = image.width
                    , height = image.height
                    }
                , crop = model.crop
                , resized =
                    { width = round size.x
                    , height = round size.y
                    }
                , origin =
                    { x = round origin.x
                    , y = round origin.y
                    }
                }
