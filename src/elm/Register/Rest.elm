module Register.Rest exposing (registerUser)

import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline as DecodePipeline exposing (required)

import Register.Types exposing (RegistrationForm, Msg(..))
import Types exposing (User)

userDecoder : Decode.Decoder User
userDecoder =
  DecodePipeline.decode User
    |> required "first_name" Decode.string
    |> required "last_name" Decode.string
    |> required "username" Decode.string
    |> required "email" Decode.string


registerUser : RegistrationForm -> Cmd Msg
registerUser
  { firstName
  , lastName
  , username
  , email
  , password
  } =
    let
      accountData = Encode.object
        [ ("first_name", Encode.string firstName)
        , ("last_name", Encode.string lastName)
        , ("username", Encode.string username)
        , ("email", Encode.string email)
        , ("password", Encode.string password)
        ]

      body = Http.jsonBody accountData

      request = Http.post "http://localhost:5000/register" body userDecoder
    in
      Http.send RegisterResult request
