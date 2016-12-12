module Rest exposing (silentLogin)

import Http

import Messages exposing (..)
import Config exposing (apiUrl)
import Helpers.Rest
import Decoder exposing (userDecoder)

silentLogin : String -> Cmd Msg
silentLogin accessToken =
  let
    request = Helpers.Rest.secureRequest
      { url = apiUrl ++ "/account"
      , body = Http.emptyBody
      , decoder = userDecoder
      , method = "GET"
      , accessToken = accessToken
      }
  in
    Http.send SilentLoginResult request
