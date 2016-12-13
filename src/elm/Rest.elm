module Rest exposing (..)

import Http
import Json.Decode exposing (list)

import Messages exposing (..)
import Config exposing (apiUrl)
import Helpers.Rest
import Decoder exposing (..)

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

fetchProjects : String -> Cmd Msg
fetchProjects accessToken =
  let
    request = Helpers.Rest.secureRequest
      { url = apiUrl ++ "/projects"
      , body = Http.emptyBody
      , decoder = list projectDecoder
      , method = "GET"
      , accessToken = accessToken
      }
  in
    Http.send ProjectsResult request