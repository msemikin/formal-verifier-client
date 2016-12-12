module Helpers.Rest exposing (secureRequest)

import Json.Decode exposing (Decoder)
import Http exposing (..)

type alias SecureSendPayload d =
  {
    url : String
  , method : String
  , body : Body
  , decoder : Decoder d
  , accessToken : String
  }

secureRequest : SecureSendPayload d -> Request d
secureRequest { method, body, decoder, accessToken, url } =
  request
    { method = method
    , url = url
    , body = body
    , expect = expectJson decoder
    , headers = [header "Authorization" ("Bearer " ++ accessToken)]
    , timeout = Nothing
    , withCredentials = False
    }