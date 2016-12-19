module Rest exposing (..)

import Http
import Json.Decode exposing (list)

import Messages exposing (..)
import Config exposing (apiUrl)
import Helpers.Rest
import Decoder exposing (..)

silentLogin : String -> Cmd Msg
silentLogin accessToken =
  Helpers.Rest.secureRequest SilentLoginResult 
    { url = apiUrl ++ "/account"
    , body = Http.emptyBody
    , decoder = userDecoder
    , method = "GET"
    , accessToken = accessToken
    }

fetchProjects : String -> Cmd Msg
fetchProjects accessToken =
  Helpers.Rest.secureRequest ProjectsResult 
    { url = apiUrl ++ "/projects"
    , body = Http.emptyBody
    , decoder = list projectDecoder
    , method = "GET"
    , accessToken = accessToken
    }