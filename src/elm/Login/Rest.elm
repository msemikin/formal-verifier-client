module Login.Rest exposing (loginUser)

import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline as DecodePipeline exposing (required)

import Login.Types exposing (LoginForm, Msg(..))
import Config exposing (apiUrl)
import Types exposing (LoginResponse)
import Decoder exposing (userDecoder)

loginResultDecoder : Decode.Decoder LoginResponse
loginResultDecoder =
  DecodePipeline.decode LoginResponse
    |> required "access_token" Decode.string
    |> required "user" userDecoder

loginUser : LoginForm -> Cmd Msg
loginUser
  { username
  , password
  } =
    let
      accountData = Encode.object
        [ ("username", Encode.string username)
        , ("password", Encode.string password)
        ]

      body = Http.jsonBody accountData

      request = Http.post (apiUrl ++ "/login") body loginResultDecoder
    in
      Http.send LoginResult request