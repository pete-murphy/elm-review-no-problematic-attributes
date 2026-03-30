module ImplicitRole exposing (implicitRole)

{-| Determine the implicit ARIA role of an HTML element based on its tag name
and attributes, per the W3C "ARIA in HTML" specification.
-}

import Dict exposing (Dict)


{-| Given an HTML element tag name and a dict of attribute names to their
string values, return the element's implicit ARIA role per the
"ARIA in HTML" W3C spec, or Nothing if there is no corresponding role.
-}
implicitRole : String -> Dict String String -> Maybe String
implicitRole tagName attributes =
    case tagName of
        "a" ->
            if Dict.member "href" attributes then
                Just "link"

            else
                Just "generic"

        "address" ->
            Just "group"

        "area" ->
            if Dict.member "href" attributes then
                Just "link"

            else
                Just "generic"

        "article" ->
            Just "article"

        "aside" ->
            Just "complementary"

        "b" ->
            Just "generic"

        "blockquote" ->
            Just "blockquote"

        "button" ->
            Just "button"

        "code" ->
            Just "code"

        "datalist" ->
            Just "listbox"

        "del" ->
            Just "deletion"

        "details" ->
            Just "group"

        "dialog" ->
            Just "dialog"

        "div" ->
            Just "generic"

        "em" ->
            Just "emphasis"

        "fieldset" ->
            Just "group"

        "footer" ->
            -- Note: context-dependent in real DOM (contentinfo only when not
            -- inside article/aside/main/nav/section). We default to contentinfo
            -- since static analysis can't check ancestors.
            Just "contentinfo"

        "form" ->
            Just "form"

        "h1" ->
            Just "heading"

        "h2" ->
            Just "heading"

        "h3" ->
            Just "heading"

        "h4" ->
            Just "heading"

        "h5" ->
            Just "heading"

        "h6" ->
            Just "heading"

        "header" ->
            -- Note: context-dependent in real DOM (banner only when not inside
            -- article/aside/main/nav/section). We default to banner since
            -- static analysis can't check ancestors.
            Just "banner"

        "hr" ->
            Just "separator"

        "i" ->
            Just "generic"

        "img" ->
            case Dict.get "alt" attributes of
                Just "" ->
                    Just "presentation"

                _ ->
                    Just "img"

        "input" ->
            inputRole attributes

        "ins" ->
            Just "insertion"

        "li" ->
            Just "listitem"

        "main" ->
            Just "main"

        "menu" ->
            Just "list"

        "meter" ->
            Just "meter"

        "nav" ->
            Just "navigation"

        "ol" ->
            Just "list"

        "option" ->
            Just "option"

        "output" ->
            Just "status"

        "p" ->
            Just "paragraph"

        "pre" ->
            Just "generic"

        "progress" ->
            Just "progressbar"

        "search" ->
            Just "search"

        "section" ->
            if hasAccessibleName attributes then
                Just "region"

            else
                Just "generic"

        "select" ->
            if Dict.member "multiple" attributes then
                Just "listbox"

            else
                Just "combobox"

        "span" ->
            Just "generic"

        "strong" ->
            Just "strong"

        "sub" ->
            Just "subscript"

        "sup" ->
            Just "superscript"

        "table" ->
            Just "table"

        "tbody" ->
            Just "rowgroup"

        "td" ->
            Just "cell"

        "textarea" ->
            Just "textbox"

        "tfoot" ->
            Just "rowgroup"

        "th" ->
            Just "columnheader"

        "thead" ->
            Just "rowgroup"

        "time" ->
            Just "time"

        "tr" ->
            Just "row"

        "ul" ->
            Just "list"

        _ ->
            Nothing


inputRole : Dict String String -> Maybe String
inputRole attributes =
    case Dict.get "type" attributes of
        Nothing ->
            Just "textbox"

        Just inputType ->
            case inputType of
                "button" ->
                    Just "button"

                "checkbox" ->
                    Just "checkbox"

                "email" ->
                    Just "textbox"

                "hidden" ->
                    Nothing

                "image" ->
                    Just "button"

                "number" ->
                    Just "spinbutton"

                "password" ->
                    Just "textbox"

                "radio" ->
                    Just "radio"

                "range" ->
                    Just "slider"

                "reset" ->
                    Just "button"

                "search" ->
                    Just "searchbox"

                "submit" ->
                    Just "button"

                "tel" ->
                    Just "textbox"

                "url" ->
                    Just "textbox"

                _ ->
                    Just "textbox"


hasAccessibleName : Dict String String -> Bool
hasAccessibleName attributes =
    Dict.member "aria-label" attributes || Dict.member "aria-labelledby" attributes
