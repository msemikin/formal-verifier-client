import Navigation
import State exposing (init, update)
import View exposing (view)
import Messages exposing (Msg(UrlChange))

main =
  Navigation.program UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    }
