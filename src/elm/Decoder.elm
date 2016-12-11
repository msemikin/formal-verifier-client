module Decoder exposing (userDecoder)

import Json.Decode as Decode
import Json.Decode.Pipeline as DecodePipeline exposing (required)

import Types exposing (User)

userDecoder : Decode.Decoder User
userDecoder =
  DecodePipeline.decode User
    |> required "first_name" Decode.string
    |> required "last_name" Decode.string
    |> required "username" Decode.string
    |> required "email" Decode.string

