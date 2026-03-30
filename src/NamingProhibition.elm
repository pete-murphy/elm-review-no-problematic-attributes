module NamingProhibition exposing (namingProhibited)

{-| Returns True if the given ARIA role prohibits naming from author
(aria-label, aria-labelledby). Per WAI-ARIA 1.2 spec.
-}

import Set exposing (Set)


namingProhibited : String -> Bool
namingProhibited role =
    Set.member role prohibitedRoles


prohibitedRoles : Set String
prohibitedRoles =
    Set.fromList
        [ "caption"
        , "code"
        , "definition"
        , "deletion"
        , "emphasis"
        , "generic"
        , "insertion"
        , "none"
        , "paragraph"
        , "presentation"
        , "strong"
        , "subscript"
        , "superscript"
        , "term"
        , "time"
        ]
