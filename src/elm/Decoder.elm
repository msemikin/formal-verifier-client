module Decoder exposing (..)

import Dict
import Json.Decode exposing (..)
import Json.Decode.Pipeline as DecodePipeline exposing (required, requiredAt)

import Types exposing (..)

loginResultDecoder : Decoder LoginResponse
loginResultDecoder =
  DecodePipeline.decode LoginResponse
    |> required "access_token" string
    |> required "user" userDecoder

modelDecoder : Decoder LTS
modelDecoder =
  DecodePipeline.decode LTS
    |> requiredAt ["_id", "$oid"] string
    |> required "name" string
    |> required "graph" string
    |> required "source" string
    |> required "formulas" (list string)

projectDecoder : Decoder Project
projectDecoder =
  DecodePipeline.decode Project
    |> requiredAt ["_id", "$oid"] string
    |> required "name" string
    |> required "description" string
    |> required "models" (list modelDecoder
      |> map (List.map (\lts -> ( lts.id, lts )) >> Dict.fromList)
    )


userDecoder : Decoder User
userDecoder =
  DecodePipeline.decode User
    |> required "first_name" string
    |> required "last_name" string
    |> required "username" string
    |> required "email" string

