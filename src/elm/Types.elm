module Types exposing (..)

import Dict exposing (Dict)

type Route =
    RegisterRoute
  | LoginRoute
  | ProfileRoute
  | ProjectRoute String
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

type alias LTS =
  { name : String
  , graph : String
  , source : String
  , formulas : List String
  }

type alias Project =
  { id : String
  , name : String
  , description : String
  , models : Dict String LTS
  }
