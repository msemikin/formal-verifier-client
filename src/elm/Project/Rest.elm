module Project.Rest exposing (..)

import Http
import Result
import Json.Encode as Encode
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline as DecodePipeline exposing (required)

import Project.Types exposing (..)
import Helpers.Rest
import Config exposing (apiUrl)
import Decoder exposing (..)

decodeValidationResult : Decoder ValidationResult
decodeValidationResult =
  DecodePipeline.decode ValidationResult
    |> required "graph" string
    |> required "valid" bool
  

createModel : String -> ModelForm -> String -> Cmd Msg
createModel projectId { name } accessToken =
  let
    data = Encode.object
      [ ("name", Encode.string name)
      ]
  in
    Helpers.Rest.secureRequest CreateModelResult
      { url = apiUrl ++ "/projects/" ++ projectId ++ "/models"
      , body = Http.jsonBody data
      , decoder = modelDecoder
      , method = "POST"
      , accessToken = accessToken
      }


updateModel : String -> String -> String -> String -> Cmd Msg
updateModel projectId modelId modelSource accessToken =
  let
    data = Encode.object
      [ ("source", Encode.string modelSource)
      ]
  in
    Helpers.Rest.secureRequest UpdateModelResult
      { url = apiUrl ++ "/projects/" ++ projectId ++ "/models/" ++ modelId
      , body = Http.jsonBody data
      , decoder = modelDecoder
      , method = "PUT"
      , accessToken = accessToken
      }
 

patchModel : String -> String -> List String -> String -> Cmd Msg
patchModel projectId modelId formulas accessToken =
  let
    data = Encode.object
      [ ("formulas", Encode.list <| List.map Encode.string formulas)]
  in
    Helpers.Rest.secureRequest UpdateModelResult
      { url = apiUrl ++ "/projects/" ++ projectId ++ "/models/" ++ modelId
      , body = Http.jsonBody data
      , decoder = modelDecoder
      , method = "PATCH"
      , accessToken = accessToken
      }



fetchProject : String -> String -> Cmd Msg
fetchProject id accessToken =
  Helpers.Rest.secureRequest ProjectResult
      { url = apiUrl ++ "/projects/" ++ id
      , body = Http.emptyBody
      , decoder = projectDecoder
      , method = "GET"
      , accessToken = accessToken
      }

checkModel : String -> String -> String -> Cmd Msg
checkModel projectId modelId accessToken =
  Helpers.Rest.secureRequest CheckModelResult
    { url = apiUrl ++ "/projects/" ++ projectId ++ "/models/" ++ modelId ++ "/check"
    , body = Http.emptyBody
    , decoder = Decode.dict decodeValidationResult
    , method = "POST"
    , accessToken = accessToken
    }

deleteModel : String -> String -> String -> Cmd Msg
deleteModel projectId modelId accessToken =
  Helpers.Rest.secureRequest DeleteModelResult
    { url = apiUrl ++ "/projects/" ++ projectId ++ "/models/" ++ modelId
    , body = Http.emptyBody
    , decoder = Decode.field "success" Decode.bool
    , method = "DELETE"
    , accessToken = accessToken
    } |> Cmd.map (\result -> result modelId)