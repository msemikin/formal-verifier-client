module Routing exposing (..)

import Debug
import RouteUrl exposing (UrlChange)
import RouteUrl.Builder as Builder exposing (..)
import Navigation exposing (Location)

import Model exposing (Model)
import Messages exposing (Msg(..))
import Types exposing (..)


delta2url : Model -> Model -> Maybe UrlChange
delta2url previous current =
  Just <| Builder.toUrlChange <|
    delta2builder previous current


delta2builder : Model -> Model -> Builder
delta2builder previous current =
  case current.currentRoute of
    RegisterRoute ->
      builder |> prependToPath [ "register" ]
    
    LoginRoute ->
      builder |> prependToPath [ "login" ]
    
    ProfileRoute ->
      builder |> prependToPath [ "profile" ]
    
    ProjectRoute projectId ->
      builder |> prependToPath [ "projects", projectId ]

    NotFoundRoute ->
      builder |> prependToPath [ "notfound" ]


location2messages : Location -> List Msg
location2messages location =
  let
    builder = (Builder.fromUrl location.href)
  in
    case Builder.path builder of
      first :: rest ->
        case first of
          "register" ->
            [ UpdateRoute RegisterRoute ]

          "login" ->
            [ UpdateRoute LoginRoute ]

          "profile" ->
            [ UpdateRoute ProfileRoute ]
          
          "projects" ->
            case rest of
              projectId :: _ ->
                [ UpdateRoute <| ProjectRoute projectId ]
              [] ->
                [ UpdateRoute NotFoundRoute ]
          
          _ ->
            [ UpdateRoute NotFoundRoute ]

      _ ->
        [ UpdateRoute NotFoundRoute ]