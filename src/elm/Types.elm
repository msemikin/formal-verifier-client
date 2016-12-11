module Types exposing (User, LoginResponse)

type alias User =
  { firstName: String
  , lastName: String
  , username: String
  , email: String
  }

type alias LoginResponse =
  { accessToken: String
  , user: User
  }
