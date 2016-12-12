module Rest exposing (fetchProjects)

import Http

import Messages exposing (Msg(..))
import Helpers.Rest
import Config exposing (apiUrl)
import Decoder exposing (projectDecoder)
import Json.Decode exposing (list)

fetchProjects : String -> Cmd Msg
fetchProjects sessionToken =
    let
      request = Helpers.Rest.secureRequest
        { url = apiUrl ++ "/login"
        , body = Http.emptyBody
        , decoder = list projectDecoder
        , method = "GET"
        , sessionToken = sessionToken
        }
    in
      Http.send ProjectsResult request
