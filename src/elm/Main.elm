module Main exposing (..)

import RouteUrl exposing (RouteUrlProgram)

import Routing exposing (..)
import State exposing (init, update, subscriptions)
import View exposing (view)
import Model exposing (Model)
import Messages exposing (Msg)


main : RouteUrlProgram Never Model Msg
main =
  RouteUrl.program
    { delta2url = delta2url
    , location2messages = location2messages
    , init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
