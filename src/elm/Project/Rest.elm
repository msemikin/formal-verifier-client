module Project.Rest exposing (..)

import Http
import Json.Encode as Encode
import Json.Decode as Decode

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


updateModel : String -> String -> String -> String -> Cmd Msg
updateModel projectId modelName modelSource accessToken =
  let
    data = Encode.object
      [ ("source", Encode.string modelSource)
      ]
    
    request = Helpers.Rest.secureRequest
      { url = apiUrl ++ "/projects/" ++ projectId ++ "/models/" ++ modelName
      , body = Http.jsonBody data
      , decoder = modelDecoder
      , method = "PUT"
      , accessToken = accessToken
      }
  in
    Http.send UpdateModelResult request
 

patchModel : String -> String -> List String -> String -> Cmd Msg
patchModel projectId modelName formulas accessToken =
  let
    data = Encode.object
      [ ("formulas", Encode.list <| List.map Encode.string formulas)]

    request = Helpers.Rest.secureRequest
      { url = apiUrl ++ "/projects/" ++ projectId ++ "/models/" ++ modelName
      , body = Http.jsonBody data
      , decoder = modelDecoder
      , method = "PATCH"
      , accessToken = accessToken
      }
  in
    Http.send UpdateModelResult request



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