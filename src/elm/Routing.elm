module Routing exposing (Route(..), parseLocation)

import Navigation exposing (Location)
import UrlParser exposing (..)

type Route =
    RegistrationRoute
  | LoginRoute
  | NotFoundRoute


matchers : Parser (Route -> a) a
matchers = oneOf
  [ map RegistrationRoute top
  , map RegistrationRoute (s "register")
  , map LoginRoute (s "login")
  ]


parseLocation : Location -> Route
parseLocation location =
  case (parseHash matchers location) of
    Just route -> route
    Nothing -> NotFoundRoute