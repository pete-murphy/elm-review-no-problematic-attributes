module ImplicitRoleTest exposing (all)

import Dict
import Expect
import ImplicitRole
import Test exposing (Test, describe, test)


all : Test
all =
    describe "ImplicitRole.implicitRole"
        [ unconditionalRoles
        , conditionalRoles
        , unknownElements
        ]


unconditionalRoles : Test
unconditionalRoles =
    describe "unconditional roles"
        [ test "button -> button" <|
            \() ->
                ImplicitRole.implicitRole "button" Dict.empty
                    |> Expect.equal (Just "button")
        , test "nav -> navigation" <|
            \() ->
                ImplicitRole.implicitRole "nav" Dict.empty
                    |> Expect.equal (Just "navigation")
        , test "main -> main" <|
            \() ->
                ImplicitRole.implicitRole "main" Dict.empty
                    |> Expect.equal (Just "main")
        , test "div -> generic" <|
            \() ->
                ImplicitRole.implicitRole "div" Dict.empty
                    |> Expect.equal (Just "generic")
        , test "span -> generic" <|
            \() ->
                ImplicitRole.implicitRole "span" Dict.empty
                    |> Expect.equal (Just "generic")
        , test "h1 -> heading" <|
            \() ->
                ImplicitRole.implicitRole "h1" Dict.empty
                    |> Expect.equal (Just "heading")
        , test "h2 -> heading" <|
            \() ->
                ImplicitRole.implicitRole "h2" Dict.empty
                    |> Expect.equal (Just "heading")
        , test "h3 -> heading" <|
            \() ->
                ImplicitRole.implicitRole "h3" Dict.empty
                    |> Expect.equal (Just "heading")
        , test "h4 -> heading" <|
            \() ->
                ImplicitRole.implicitRole "h4" Dict.empty
                    |> Expect.equal (Just "heading")
        , test "h5 -> heading" <|
            \() ->
                ImplicitRole.implicitRole "h5" Dict.empty
                    |> Expect.equal (Just "heading")
        , test "h6 -> heading" <|
            \() ->
                ImplicitRole.implicitRole "h6" Dict.empty
                    |> Expect.equal (Just "heading")
        , test "ul -> list" <|
            \() ->
                ImplicitRole.implicitRole "ul" Dict.empty
                    |> Expect.equal (Just "list")
        , test "ol -> list" <|
            \() ->
                ImplicitRole.implicitRole "ol" Dict.empty
                    |> Expect.equal (Just "list")
        , test "li -> listitem" <|
            \() ->
                ImplicitRole.implicitRole "li" Dict.empty
                    |> Expect.equal (Just "listitem")
        , test "article -> article" <|
            \() ->
                ImplicitRole.implicitRole "article" Dict.empty
                    |> Expect.equal (Just "article")
        , test "aside -> complementary" <|
            \() ->
                ImplicitRole.implicitRole "aside" Dict.empty
                    |> Expect.equal (Just "complementary")
        , test "details -> group" <|
            \() ->
                ImplicitRole.implicitRole "details" Dict.empty
                    |> Expect.equal (Just "group")
        , test "dialog -> dialog" <|
            \() ->
                ImplicitRole.implicitRole "dialog" Dict.empty
                    |> Expect.equal (Just "dialog")
        , test "hr -> separator" <|
            \() ->
                ImplicitRole.implicitRole "hr" Dict.empty
                    |> Expect.equal (Just "separator")
        , test "textarea -> textbox" <|
            \() ->
                ImplicitRole.implicitRole "textarea" Dict.empty
                    |> Expect.equal (Just "textbox")
        , test "output -> status" <|
            \() ->
                ImplicitRole.implicitRole "output" Dict.empty
                    |> Expect.equal (Just "status")
        , test "progress -> progressbar" <|
            \() ->
                ImplicitRole.implicitRole "progress" Dict.empty
                    |> Expect.equal (Just "progressbar")
        , test "meter -> meter" <|
            \() ->
                ImplicitRole.implicitRole "meter" Dict.empty
                    |> Expect.equal (Just "meter")
        , test "table -> table" <|
            \() ->
                ImplicitRole.implicitRole "table" Dict.empty
                    |> Expect.equal (Just "table")
        , test "tbody -> rowgroup" <|
            \() ->
                ImplicitRole.implicitRole "tbody" Dict.empty
                    |> Expect.equal (Just "rowgroup")
        , test "thead -> rowgroup" <|
            \() ->
                ImplicitRole.implicitRole "thead" Dict.empty
                    |> Expect.equal (Just "rowgroup")
        , test "tfoot -> rowgroup" <|
            \() ->
                ImplicitRole.implicitRole "tfoot" Dict.empty
                    |> Expect.equal (Just "rowgroup")
        , test "tr -> row" <|
            \() ->
                ImplicitRole.implicitRole "tr" Dict.empty
                    |> Expect.equal (Just "row")
        , test "td -> cell" <|
            \() ->
                ImplicitRole.implicitRole "td" Dict.empty
                    |> Expect.equal (Just "cell")
        , test "th -> columnheader" <|
            \() ->
                ImplicitRole.implicitRole "th" Dict.empty
                    |> Expect.equal (Just "columnheader")
        , test "datalist -> listbox" <|
            \() ->
                ImplicitRole.implicitRole "datalist" Dict.empty
                    |> Expect.equal (Just "listbox")
        , test "option -> option" <|
            \() ->
                ImplicitRole.implicitRole "option" Dict.empty
                    |> Expect.equal (Just "option")
        , test "dl -> no corresponding role" <|
            \() ->
                ImplicitRole.implicitRole "dl" Dict.empty
                    |> Expect.equal Nothing
        , test "address -> group" <|
            \() ->
                ImplicitRole.implicitRole "address" Dict.empty
                    |> Expect.equal (Just "group")
        , test "fieldset -> group" <|
            \() ->
                ImplicitRole.implicitRole "fieldset" Dict.empty
                    |> Expect.equal (Just "group")
        , test "legend -> no corresponding role" <|
            \() ->
                ImplicitRole.implicitRole "legend" Dict.empty
                    |> Expect.equal Nothing
        , test "menu -> list" <|
            \() ->
                ImplicitRole.implicitRole "menu" Dict.empty
                    |> Expect.equal (Just "list")
        , test "header -> banner" <|
            \() ->
                ImplicitRole.implicitRole "header" Dict.empty
                    |> Expect.equal (Just "banner")
        , test "footer -> contentinfo" <|
            \() ->
                ImplicitRole.implicitRole "footer" Dict.empty
                    |> Expect.equal (Just "contentinfo")
        , test "b -> generic" <|
            \() ->
                ImplicitRole.implicitRole "b" Dict.empty
                    |> Expect.equal (Just "generic")
        , test "i -> generic" <|
            \() ->
                ImplicitRole.implicitRole "i" Dict.empty
                    |> Expect.equal (Just "generic")
        , test "strong -> strong" <|
            \() ->
                ImplicitRole.implicitRole "strong" Dict.empty
                    |> Expect.equal (Just "strong")
        , test "em -> emphasis" <|
            \() ->
                ImplicitRole.implicitRole "em" Dict.empty
                    |> Expect.equal (Just "emphasis")
        , test "p -> paragraph" <|
            \() ->
                ImplicitRole.implicitRole "p" Dict.empty
                    |> Expect.equal (Just "paragraph")
        , test "pre -> generic" <|
            \() ->
                ImplicitRole.implicitRole "pre" Dict.empty
                    |> Expect.equal (Just "generic")
        , test "blockquote -> blockquote" <|
            \() ->
                ImplicitRole.implicitRole "blockquote" Dict.empty
                    |> Expect.equal (Just "blockquote")
        , test "code -> code" <|
            \() ->
                ImplicitRole.implicitRole "code" Dict.empty
                    |> Expect.equal (Just "code")
        , test "del -> deletion" <|
            \() ->
                ImplicitRole.implicitRole "del" Dict.empty
                    |> Expect.equal (Just "deletion")
        , test "ins -> insertion" <|
            \() ->
                ImplicitRole.implicitRole "ins" Dict.empty
                    |> Expect.equal (Just "insertion")
        , test "sub -> subscript" <|
            \() ->
                ImplicitRole.implicitRole "sub" Dict.empty
                    |> Expect.equal (Just "subscript")
        , test "sup -> superscript" <|
            \() ->
                ImplicitRole.implicitRole "sup" Dict.empty
                    |> Expect.equal (Just "superscript")
        , test "time -> time" <|
            \() ->
                ImplicitRole.implicitRole "time" Dict.empty
                    |> Expect.equal (Just "time")
        , test "search -> search" <|
            \() ->
                ImplicitRole.implicitRole "search" Dict.empty
                    |> Expect.equal (Just "search")
        ]


conditionalRoles : Test
conditionalRoles =
    describe "conditional roles"
        [ test "a with href -> link" <|
            \() ->
                ImplicitRole.implicitRole "a" (Dict.singleton "href" "/")
                    |> Expect.equal (Just "link")
        , test "a without href -> generic" <|
            \() ->
                ImplicitRole.implicitRole "a" Dict.empty
                    |> Expect.equal (Just "generic")
        , test "area with href -> link" <|
            \() ->
                ImplicitRole.implicitRole "area" (Dict.singleton "href" "/")
                    |> Expect.equal (Just "link")
        , test "area without href -> generic" <|
            \() ->
                ImplicitRole.implicitRole "area" Dict.empty
                    |> Expect.equal (Just "generic")
        , test "img with empty alt -> presentation" <|
            \() ->
                ImplicitRole.implicitRole "img" (Dict.singleton "alt" "")
                    |> Expect.equal (Just "presentation")
        , test "img with non-empty alt -> img" <|
            \() ->
                ImplicitRole.implicitRole "img" (Dict.singleton "alt" "A photo")
                    |> Expect.equal (Just "img")
        , test "img without alt -> img" <|
            \() ->
                ImplicitRole.implicitRole "img" Dict.empty
                    |> Expect.equal (Just "img")
        , test "input default -> textbox" <|
            \() ->
                ImplicitRole.implicitRole "input" Dict.empty
                    |> Expect.equal (Just "textbox")
        , test "input type=checkbox -> checkbox" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "checkbox")
                    |> Expect.equal (Just "checkbox")
        , test "input type=radio -> radio" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "radio")
                    |> Expect.equal (Just "radio")
        , test "input type=range -> slider" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "range")
                    |> Expect.equal (Just "slider")
        , test "input type=button -> button" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "button")
                    |> Expect.equal (Just "button")
        , test "input type=submit -> button" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "submit")
                    |> Expect.equal (Just "button")
        , test "input type=reset -> button" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "reset")
                    |> Expect.equal (Just "button")
        , test "input type=image -> button" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "image")
                    |> Expect.equal (Just "button")
        , test "input type=hidden -> no role" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "hidden")
                    |> Expect.equal Nothing
        , test "input type=number -> spinbutton" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "number")
                    |> Expect.equal (Just "spinbutton")
        , test "input type=search -> searchbox" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "search")
                    |> Expect.equal (Just "searchbox")
        , test "input type=email -> textbox" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "email")
                    |> Expect.equal (Just "textbox")
        , test "input type=tel -> textbox" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "tel")
                    |> Expect.equal (Just "textbox")
        , test "input type=url -> textbox" <|
            \() ->
                ImplicitRole.implicitRole "input" (Dict.singleton "type" "url")
                    |> Expect.equal (Just "textbox")
        , test "select without multiple -> combobox" <|
            \() ->
                ImplicitRole.implicitRole "select" Dict.empty
                    |> Expect.equal (Just "combobox")
        , test "select with multiple -> listbox" <|
            \() ->
                ImplicitRole.implicitRole "select" (Dict.singleton "multiple" "")
                    |> Expect.equal (Just "listbox")
        , test "section with aria-label -> region" <|
            \() ->
                ImplicitRole.implicitRole "section" (Dict.singleton "aria-label" "Main content")
                    |> Expect.equal (Just "region")
        , test "section with aria-labelledby -> region" <|
            \() ->
                ImplicitRole.implicitRole "section" (Dict.singleton "aria-labelledby" "heading-id")
                    |> Expect.equal (Just "region")
        , test "section without accessible name -> generic" <|
            \() ->
                ImplicitRole.implicitRole "section" Dict.empty
                    |> Expect.equal (Just "generic")
        , test "form with aria-label -> form" <|
            \() ->
                ImplicitRole.implicitRole "form" (Dict.singleton "aria-label" "Search")
                    |> Expect.equal (Just "form")
        , test "form without accessible name -> form" <|
            \() ->
                ImplicitRole.implicitRole "form" Dict.empty
                    |> Expect.equal (Just "form")
        ]


unknownElements : Test
unknownElements =
    describe "unknown elements"
        [ test "unknown tag -> Nothing" <|
            \() ->
                ImplicitRole.implicitRole "foobar" Dict.empty
                    |> Expect.equal Nothing
        , test "empty string -> Nothing" <|
            \() ->
                ImplicitRole.implicitRole "" Dict.empty
                    |> Expect.equal Nothing
        ]
