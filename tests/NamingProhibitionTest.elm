module NamingProhibitionTest exposing (all)

import Expect
import NamingProhibition
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NamingProhibition.namingProhibited"
        [ prohibitedRoles
        , allowedRoles
        ]


prohibitedRoles : Test
prohibitedRoles =
    describe "roles that prohibit naming"
        [ test "generic -> True" <|
            \() ->
                NamingProhibition.namingProhibited "generic"
                    |> Expect.equal True
        , test "none -> True" <|
            \() ->
                NamingProhibition.namingProhibited "none"
                    |> Expect.equal True
        , test "presentation -> True" <|
            \() ->
                NamingProhibition.namingProhibited "presentation"
                    |> Expect.equal True
        , test "caption -> True" <|
            \() ->
                NamingProhibition.namingProhibited "caption"
                    |> Expect.equal True
        , test "code -> True" <|
            \() ->
                NamingProhibition.namingProhibited "code"
                    |> Expect.equal True
        , test "definition -> True" <|
            \() ->
                NamingProhibition.namingProhibited "definition"
                    |> Expect.equal True
        , test "deletion -> True" <|
            \() ->
                NamingProhibition.namingProhibited "deletion"
                    |> Expect.equal True
        , test "emphasis -> True" <|
            \() ->
                NamingProhibition.namingProhibited "emphasis"
                    |> Expect.equal True
        , test "insertion -> True" <|
            \() ->
                NamingProhibition.namingProhibited "insertion"
                    |> Expect.equal True
        , test "paragraph -> True" <|
            \() ->
                NamingProhibition.namingProhibited "paragraph"
                    |> Expect.equal True
        , test "strong -> True" <|
            \() ->
                NamingProhibition.namingProhibited "strong"
                    |> Expect.equal True
        , test "subscript -> True" <|
            \() ->
                NamingProhibition.namingProhibited "subscript"
                    |> Expect.equal True
        , test "superscript -> True" <|
            \() ->
                NamingProhibition.namingProhibited "superscript"
                    |> Expect.equal True
        , test "term -> True" <|
            \() ->
                NamingProhibition.namingProhibited "term"
                    |> Expect.equal True
        , test "time -> True" <|
            \() ->
                NamingProhibition.namingProhibited "time"
                    |> Expect.equal True
        ]


allowedRoles : Test
allowedRoles =
    describe "roles that allow naming"
        [ test "button -> False" <|
            \() ->
                NamingProhibition.namingProhibited "button"
                    |> Expect.equal False
        , test "link -> False" <|
            \() ->
                NamingProhibition.namingProhibited "link"
                    |> Expect.equal False
        , test "navigation -> False" <|
            \() ->
                NamingProhibition.namingProhibited "navigation"
                    |> Expect.equal False
        , test "heading -> False" <|
            \() ->
                NamingProhibition.namingProhibited "heading"
                    |> Expect.equal False
        , test "region -> False" <|
            \() ->
                NamingProhibition.namingProhibited "region"
                    |> Expect.equal False
        , test "textbox -> False" <|
            \() ->
                NamingProhibition.namingProhibited "textbox"
                    |> Expect.equal False
        , test "img -> False" <|
            \() ->
                NamingProhibition.namingProhibited "img"
                    |> Expect.equal False
        , test "unknown role -> False" <|
            \() ->
                NamingProhibition.namingProhibited "foobar"
                    |> Expect.equal False
        ]
