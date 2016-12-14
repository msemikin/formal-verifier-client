module Decoder exposing (..)

import Dict
import Json.Decode exposing (..)
import Json.Decode.Pipeline as DecodePipeline exposing (required, requiredAt)

import Types exposing (..)

modelDecoder : Decoder LTS
modelDecoder =
  DecodePipeline.decode LTS
    |> required "name" string
    |> required "graph" string

projectDecoder : Decoder Project
projectDecoder =
  DecodePipeline.decode Project
    |> requiredAt ["_id", "$oid"] string
    |> required "name" string
    |> required "description" string
    |> required "models" (list modelDecoder
      |> map (List.map (\lts -> ( lts.name, lts )) >> Dict.fromList)
    )


userDecoder : Decoder User
userDecoder =
  DecodePipeline.decode User
    |> required "first_name" string
    |> required "last_name" string
    |> required "username" string
    |> required "email" string

