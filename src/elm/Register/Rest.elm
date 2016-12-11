module Register.Rest exposing (registerUser)

import Http
import Json.Encode as Encode

import Register.Types exposing (RegistrationForm, Msg(..))
import Decoder exposing (userDecoder)
import Config exposing (apiUrl)

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

      request = Http.post (apiUrl ++ "/register") body userDecoder
    in
      Http.send RegisterResult request
