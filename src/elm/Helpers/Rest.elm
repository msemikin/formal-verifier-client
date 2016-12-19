module Helpers.Rest exposing (secureRequest)

import Json.Decode exposing (Decoder)
import Http exposing (..)

type alias SecureSendPayload a =
  {
    url : String
  , method : String
  , body : Body
  , decoder : Decoder a
  , accessToken : String
  }

secureRequest : (Result Error a -> msg) -> SecureSendPayload a -> Cmd msg
secureRequest tag { method, body, decoder, accessToken, url } =
  let
    data = request
      { method = method
      , url = url
      , body = body
      , expect = expectJson decoder
      , headers = [header "Authorization" ("Bearer " ++ accessToken)]
      , timeout = Nothing
      , withCredentials = False
      }
  in
    Http.send tag data