module Types exposing (..)

type Route =
    RegisterRoute
  | LoginRoute
  | ProfileRoute
  | ProjectRoute
  | NotFoundRoute

type alias User =
  { firstName : String
  , lastName : String
  , username : String
  , email : String
  }

type alias LoginResponse =
  { accessToken : String
  , user : User
  }

type alias LTS = String

type alias Project =
  { name : String
  , description : String
  , models : List LTS
  }
