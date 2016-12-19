module Profile.Rest exposing (..)

import Http
import Json.Encode as Encode

import Profile.Types exposing (..)
import Helpers.Rest
import Config exposing (apiUrl)
import Decoder exposing (projectDecoder)

createProject : ProjectForm -> String -> Cmd Msg
createProject { name, description } accessToken =
  let
    projectData = Encode.object
      [ ("name", Encode.string name)
      , ("description", Encode.string description)
      ]
  in
    Helpers.Rest.secureRequest CreateProjectResult 
      { url = apiUrl ++ "/projects"
      , body = Http.jsonBody projectData
      , decoder = projectDecoder
      , method = "POST"
      , accessToken = accessToken
      }
