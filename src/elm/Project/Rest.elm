module Project.Rest exposing (..)

import Http
import Json.Encode as Encode

import Project.Types exposing (..)
import Helpers.Rest
import Config exposing (apiUrl)
import Decoder exposing (..)

createModel : String -> ModelForm -> String -> Cmd Msg
createModel projectId { name } accessToken =
  let
    data = Encode.object
      [ ("name", Encode.string name)
      ]

    request = Helpers.Rest.secureRequest
      { url = apiUrl ++ "/projects/" ++ projectId ++ "/models"
      , body = Http.jsonBody data
      , decoder = modelDecoder
      , method = "POST"
      , accessToken = accessToken
      }
  in
    Http.send CreateModelResult request

fetchProject : String -> String -> Cmd Msg
fetchProject id accessToken=
  let
    request = Helpers.Rest.secureRequest
      { url = apiUrl ++ "/projects/" ++ id
      , body = Http.emptyBody
      , decoder = projectDecoder
      , method = "GET"
      , accessToken = accessToken
      }
  in
    Http.send ProjectResult request