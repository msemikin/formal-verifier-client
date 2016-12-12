module Profile.Rest exposing (..)

import Http
import Json.Decode exposing (list)
import Json.Encode as Encode

import Profile.Types exposing (..)
import Helpers.Rest
import Config exposing (apiUrl)
import Decoder exposing (projectDecoder)
import Types exposing (..)

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


createProject : ProjectForm -> String -> Cmd Msg
createProject { name, description } accessToken =
  let
    projectData = Encode.object
      [ ("name", Encode.string name)
      , ("description", Encode.string description)
      ]

    request = Helpers.Rest.secureRequest
      { url = apiUrl ++ "/projects"
      , body = Http.jsonBody projectData
      , decoder = projectDecoder
      , method = "POST"
      , accessToken = accessToken
      }
  in
    Http.send CreateProjectResult request
