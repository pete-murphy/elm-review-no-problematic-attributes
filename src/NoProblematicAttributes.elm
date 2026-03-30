module NoProblematicAttributes exposing
    ( rule
    , Option, defaults, forbid, forbidWithFix, htmlClassOnSvg, noAriaLabelOnNamingProhibited
    )

{-|

@docs rule
@docs Option, defaults, forbid, forbidWithFix, htmlClassOnSvg, noAriaLabelOnNamingProhibited

-}

import Dict exposing (Dict)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import ImplicitRole
import NamingProhibition
import Review.Fix as Fix
import Review.ModuleNameLookupTable as ModuleNameLookupTable exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Rule)


{-| An option that bans a specific attribute or function. Use [`forbid`](#forbid)
or [`forbidWithFix`](#forbidWithFix) to create custom options, or use the
built-in [`defaults`](#defaults).
-}
type Option
    = BannedFunction BannedFunctionConfig
    | HtmlClassOnSvg
    | NoAriaLabelOnNamingProhibited


type alias BannedFunctionConfig =
    { moduleName : List String
    , functionName : String
    , message : String
    , details : List String
    , replaceWith : Maybe String
    }


{-| The default set of options that ban known-problematic attributes:

  - `Svg.Attributes.xlinkHref` (and all `xlink*` functions) — deprecated, causes rendering problems
  - `Svg.Attributes.style` — incompatible with Content Security Policy
  - `Html.Attributes.title` — not accessible
  - `Html.Attributes.class` on SVG elements — causes runtime error
  - `aria-label`/`aria-labelledby` on elements whose role prohibits naming (e.g. `<div>`, `<span>`)

Each is also checked for the `*.Styled.*` (elm-css) variant.

    config =
        [ NoProblematicAttributes.rule NoProblematicAttributes.defaults
        ]

-}
defaults : List Option
defaults =
    [ forbidWithFix
        { moduleName = [ "Svg", "Attributes" ]
        , functionName = "xlinkHref"
        , message = "Don't use `Svg.Attributes.xlinkHref`"
        , details =
            [ "`xlink:href` is deprecated in SVG 2.0 and causes rendering problems with Elm's virtual DOM."
            , "Use `Html.Attributes.attribute \"href\" \"...\"` instead. Note: don't use `Html.Attributes.href` since that sets the `.href` property, which is readonly in SVG."
            ]
        , replaceWith = "Html.Attributes.attribute \"href\""
        }
    , forbidWithFix
        { moduleName = [ "Svg", "Styled", "Attributes" ]
        , functionName = "xlinkHref"
        , message = "Don't use `Svg.Styled.Attributes.xlinkHref`"
        , details =
            [ "`xlink:href` is deprecated in SVG 2.0 and causes rendering problems with Elm's virtual DOM."
            , "Use `Html.Attributes.attribute \"href\" \"...\"` instead. Note: don't use `Html.Attributes.href` since that sets the `.href` property, which is readonly in SVG."
            ]
        , replaceWith = "Html.Attributes.attribute \"href\""
        }
    , xlinkOption "xlinkActuate" [ "Svg", "Attributes" ]
    , xlinkOption "xlinkActuate" [ "Svg", "Styled", "Attributes" ]
    , xlinkOption "xlinkArcrole" [ "Svg", "Attributes" ]
    , xlinkOption "xlinkArcrole" [ "Svg", "Styled", "Attributes" ]
    , xlinkOption "xlinkRole" [ "Svg", "Attributes" ]
    , xlinkOption "xlinkRole" [ "Svg", "Styled", "Attributes" ]
    , xlinkOption "xlinkShow" [ "Svg", "Attributes" ]
    , xlinkOption "xlinkShow" [ "Svg", "Styled", "Attributes" ]
    , xlinkOption "xlinkTitle" [ "Svg", "Attributes" ]
    , xlinkOption "xlinkTitle" [ "Svg", "Styled", "Attributes" ]
    , xlinkOption "xlinkType" [ "Svg", "Attributes" ]
    , xlinkOption "xlinkType" [ "Svg", "Styled", "Attributes" ]
    , forbid
        { moduleName = [ "Svg", "Attributes" ]
        , functionName = "style"
        , message = "Don't use `Svg.Attributes.style`"
        , details =
            [ "Inline style attributes are incompatible with Content Security Policy without `style-src 'unsafe-inline'`."
            , "Use class-based styling instead."
            ]
        }
    , forbid
        { moduleName = [ "Svg", "Styled", "Attributes" ]
        , functionName = "style"
        , message = "Don't use `Svg.Styled.Attributes.style`"
        , details =
            [ "Inline style attributes are incompatible with Content Security Policy without `style-src 'unsafe-inline'`."
            , "Use class-based styling instead."
            ]
        }
    , forbid
        { moduleName = [ "Html", "Attributes" ]
        , functionName = "title"
        , message = "Don't use the `Html.Attributes.title` attribute"
        , details =
            [ "The `title` attribute is discouraged because many user agents do not expose it accessibly. It typically requires a pointing device (mouse) to trigger a tooltip, excluding keyboard-only and touch-only users."
            , "See https://html.spec.whatwg.org/multipage/dom.html#the-title-attribute for more information."
            ]
        }
    , forbid
        { moduleName = [ "Html", "Styled", "Attributes" ]
        , functionName = "title"
        , message = "Don't use the `Html.Styled.Attributes.title` attribute"
        , details =
            [ "The `title` attribute is discouraged because many user agents do not expose it accessibly. It typically requires a pointing device (mouse) to trigger a tooltip, excluding keyboard-only and touch-only users."
            , "See https://html.spec.whatwg.org/multipage/dom.html#the-title-attribute for more information."
            ]
        }
    , htmlClassOnSvg
    , noAriaLabelOnNamingProhibited
    ]


xlinkOption : String -> List String -> Option
xlinkOption functionName moduleName =
    let
        qualName : String
        qualName =
            String.join "." moduleName ++ "." ++ functionName
    in
    forbid
        { moduleName = moduleName
        , functionName = functionName
        , message = "Don't use `" ++ qualName ++ "`"
        , details =
            [ "All `xlink:*` attributes are deprecated in SVG 2.0 and cause rendering problems with Elm's virtual DOM."
            , "See https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/xlink:href for more information."
            ]
        }


{-| Ban a function. The error has no automatic fix.

    NoProblematicAttributes.forbid
        { moduleName = [ "Html", "Attributes" ]
        , functionName = "contenteditable"
        , message = "Don't use contenteditable"
        , details = [ "It causes issues in our app." ]
        }

-}
forbid :
    { moduleName : List String
    , functionName : String
    , message : String
    , details : List String
    }
    -> Option
forbid config =
    BannedFunction
        { moduleName = config.moduleName
        , functionName = config.functionName
        , message = config.message
        , details = config.details
        , replaceWith = Nothing
        }


{-| Ban a function with an automatic fix that replaces it.

The `replaceWith` string replaces the function reference in source code.
Arguments are preserved thanks to currying.

    NoProblematicAttributes.forbidWithFix
        { moduleName = [ "Svg", "Attributes" ]
        , functionName = "xlinkHref"
        , message = "Don't use `Svg.Attributes.xlinkHref`"
        , details = [ "..." ]
        , replaceWith = "Html.Attributes.attribute \"href\""
        }

This would fix `Svg.Attributes.xlinkHref "#icon"` to
`Html.Attributes.attribute "href" "#icon"`.

-}
forbidWithFix :
    { moduleName : List String
    , functionName : String
    , message : String
    , details : List String
    , replaceWith : String
    }
    -> Option
forbidWithFix config =
    BannedFunction
        { moduleName = config.moduleName
        , functionName = config.functionName
        , message = config.message
        , details = config.details
        , replaceWith = Just config.replaceWith
        }


{-| Ban `Html.Attributes.class` (and `Html.Styled.Attributes.class`) when used
on SVG elements. This causes a runtime error because SVG elements have a
readonly `className` property.

The fix replaces it with `Svg.Attributes.class`.

This is included in [`defaults`](#defaults).

-}
htmlClassOnSvg : Option
htmlClassOnSvg =
    HtmlClassOnSvg


{-| Ban `aria-label` and `aria-labelledby` on elements whose ARIA role
prohibits naming from author (e.g. `<div>`, `<span>`, `<p>`).

These attributes are silently ignored by assistive technologies on such
elements, misleading developers into thinking they've provided accessible
labeling.

This is included in [`defaults`](#defaults).

-}
noAriaLabelOnNamingProhibited : Option
noAriaLabelOnNamingProhibited =
    NoAriaLabelOnNamingProhibited


{-| Reports uses of problematic HTML and SVG attributes.

    config =
        [ NoProblematicAttributes.rule NoProblematicAttributes.defaults
        ]

Use [`defaults`](#defaults) for the built-in checks, or build your own list:

    config =
        [ NoProblematicAttributes.rule
            (NoProblematicAttributes.defaults
                ++ [ NoProblematicAttributes.forbid
                        { moduleName = [ "Html", "Attributes" ]
                        , functionName = "contenteditable"
                        , message = "Don't use contenteditable"
                        , details = [ "It causes issues in our app." ]
                        }
                   ]
            )
        ]


## Fail

Using deprecated `xlink:*` SVG attributes:

    import Svg
    import Svg.Attributes

    view =
        Svg.svg []
            [ Svg.use [ Svg.Attributes.xlinkHref "#icon" ] []
            ]

Using `Html.Attributes.class` on SVG elements:

    import Html.Attributes
    import Svg
    import Svg.Attributes

    view =
        Svg.svg [ Html.Attributes.class "icon" ] []

Using inline `style` on SVG elements:

    import Svg
    import Svg.Attributes

    view =
        Svg.svg [ Svg.Attributes.style "color" "red" ] []

Using the `title` attribute:

    import Html
    import Html.Attributes

    view =
        Html.span [ Html.Attributes.title "More info" ] [ Html.text "hover me" ]


## Success

    import Html.Attributes
    import Svg
    import Svg.Attributes

    view =
        Svg.svg [ Svg.Attributes.class "icon" ]
            [ Svg.use [ Html.Attributes.attribute "href" "#icon" ] []
            ]


## When (not) to enable this rule

This rule is useful when you want to prevent runtime errors and accessibility
issues caused by problematic HTML/SVG attributes.

This rule is not useful when you intentionally use these attributes and
understand their limitations.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template pete-murphy/elm-review-no-problematic-attributes/example --rules NoProblematicAttributes
```

-}
rule : List Option -> Rule
rule options =
    let
        bannedFunctions : List BannedFunctionConfig
        bannedFunctions =
            List.filterMap getBannedFunction options

        hasHtmlClassOnSvg : Bool
        hasHtmlClassOnSvg =
            List.any isHtmlClassOnSvgOption options

        hasNoAriaLabel : Bool
        hasNoAriaLabel =
            List.any isNoAriaLabelOption options
    in
    Rule.newModuleRuleSchemaUsingContextCreator "NoProblematicAttributes" initialContext
        |> Rule.withExpressionEnterVisitor (expressionVisitor bannedFunctions hasHtmlClassOnSvg hasNoAriaLabel)
        |> Rule.fromModuleRuleSchema


getBannedFunction : Option -> Maybe BannedFunctionConfig
getBannedFunction option =
    case option of
        BannedFunction config ->
            Just config

        _ ->
            Nothing


isHtmlClassOnSvgOption : Option -> Bool
isHtmlClassOnSvgOption option =
    case option of
        HtmlClassOnSvg ->
            True

        _ ->
            False


isNoAriaLabelOption : Option -> Bool
isNoAriaLabelOption option =
    case option of
        NoAriaLabelOnNamingProhibited ->
            True

        _ ->
            False


type alias Context =
    { moduleNameLookupTable : ModuleNameLookupTable
    }


initialContext : Rule.ContextCreator () Context
initialContext =
    Rule.initContextCreator
        (\moduleNameLookupTable () ->
            { moduleNameLookupTable = moduleNameLookupTable
            }
        )
        |> Rule.withModuleNameLookupTable


expressionVisitor : List BannedFunctionConfig -> Bool -> Bool -> Node Expression -> Context -> ( List (Rule.Error {}), Context )
expressionVisitor bannedFunctions hasHtmlClassOnSvgEnabled hasNoAriaLabelEnabled node context =
    case Node.value node of
        Expression.FunctionOrValue _ name ->
            ( checkBannedFunctions bannedFunctions name node context
            , context
            )

        Expression.Application (fnNode :: attrListNode :: _) ->
            case Node.value fnNode of
                Expression.FunctionOrValue _ fnName ->
                    let
                        svgErrors : List (Rule.Error {})
                        svgErrors =
                            if hasHtmlClassOnSvgEnabled then
                                checkSvgApplication fnNode attrListNode context

                            else
                                []

                        ariaLabelErrors : List (Rule.Error {})
                        ariaLabelErrors =
                            if hasNoAriaLabelEnabled then
                                checkAriaLabelOnNamingProhibited fnNode fnName attrListNode context

                            else
                                []
                    in
                    ( svgErrors ++ ariaLabelErrors, context )

                _ ->
                    ( [], context )

        _ ->
            ( [], context )


checkBannedFunctions : List BannedFunctionConfig -> String -> Node Expression -> Context -> List (Rule.Error {})
checkBannedFunctions bannedFunctions name node context =
    let
        resolvedModule : Maybe (List String)
        resolvedModule =
            ModuleNameLookupTable.moduleNameFor context.moduleNameLookupTable node
    in
    case resolvedModule of
        Just moduleName ->
            case findBannedFunction moduleName name bannedFunctions of
                Just config ->
                    [ bannedFunctionError config node ]

                Nothing ->
                    []

        Nothing ->
            []


findBannedFunction : List String -> String -> List BannedFunctionConfig -> Maybe BannedFunctionConfig
findBannedFunction moduleName functionName configs =
    case configs of
        [] ->
            Nothing

        config :: rest ->
            if config.moduleName == moduleName && config.functionName == functionName then
                Just config

            else
                findBannedFunction moduleName functionName rest


bannedFunctionError : BannedFunctionConfig -> Node Expression -> Rule.Error {}
bannedFunctionError config node =
    case config.replaceWith of
        Just replacement ->
            Rule.errorWithFix
                { message = config.message
                , details = config.details
                }
                (Node.range node)
                [ Fix.replaceRangeBy (Node.range node) replacement ]

        Nothing ->
            Rule.error
                { message = config.message
                , details = config.details
                }
                (Node.range node)



-- Html.Attributes.class on SVG elements


checkSvgApplication : Node Expression -> Node Expression -> Context -> List (Rule.Error {})
checkSvgApplication fnNode attrListNode context =
    let
        resolvedFnModule : Maybe (List String)
        resolvedFnModule =
            ModuleNameLookupTable.moduleNameFor context.moduleNameLookupTable fnNode
    in
    if isSvgElementModule resolvedFnModule then
        checkAttrListForHtmlClass attrListNode context

    else
        []


checkAttrListForHtmlClass : Node Expression -> Context -> List (Rule.Error {})
checkAttrListForHtmlClass attrListNode context =
    case Node.value attrListNode of
        Expression.ListExpr items ->
            List.filterMap (checkSingleAttrForHtmlClass context) items

        Expression.ParenthesizedExpression inner ->
            checkAttrListForHtmlClass inner context

        _ ->
            []


checkSingleAttrForHtmlClass : Context -> Node Expression -> Maybe (Rule.Error {})
checkSingleAttrForHtmlClass context node =
    case Node.value node of
        Expression.FunctionOrValue moduleName "class" ->
            let
                resolved : Maybe (List String)
                resolved =
                    ModuleNameLookupTable.moduleNameFor context.moduleNameLookupTable node
            in
            if isHtmlAttributeModule resolved then
                Just (htmlClassOnSvgError moduleName node)

            else
                Nothing

        Expression.Application (innerNode :: _) ->
            case Node.value innerNode of
                Expression.FunctionOrValue moduleName "class" ->
                    let
                        resolved : Maybe (List String)
                        resolved =
                            ModuleNameLookupTable.moduleNameFor context.moduleNameLookupTable innerNode
                    in
                    if isHtmlAttributeModule resolved then
                        Just (htmlClassOnSvgError moduleName innerNode)

                    else
                        Nothing

                _ ->
                    Nothing

        _ ->
            Nothing


htmlClassOnSvgError : List String -> Node Expression -> Rule.Error {}
htmlClassOnSvgError moduleName node =
    let
        qualName : String
        qualName =
            qualifiedName moduleName "class"
    in
    Rule.errorWithFix
        { message = "Don't use `" ++ qualName ++ "` on SVG elements"
        , details =
            [ "Using `Html.Attributes.class` on SVG elements causes a runtime error: \"Cannot set property className of #<SVGElement> which has only a getter\"."
            , "Use `Svg.Attributes.class` instead."
            ]
        }
        (Node.range node)
        [ Fix.replaceRangeBy (Node.range node) "Svg.Attributes.class" ]



-- aria-label on naming-prohibited elements


checkAriaLabelOnNamingProhibited : Node Expression -> String -> Node Expression -> Context -> List (Rule.Error {})
checkAriaLabelOnNamingProhibited fnNode fnName attrListNode context =
    let
        resolvedFnModule : Maybe (List String)
        resolvedFnModule =
            ModuleNameLookupTable.moduleNameFor context.moduleNameLookupTable fnNode
    in
    if isHtmlElementModule resolvedFnModule then
        case Node.value attrListNode of
            Expression.ListExpr items ->
                let
                    attrInfo : AttrInfo
                    attrInfo =
                        extractAttrInfo context items
                in
                case attrInfo.ariaLabelNode of
                    Just ( ariaAttrName, ariaAttrNameNode ) ->
                        let
                            effectiveRole : Maybe String
                            effectiveRole =
                                case attrInfo.explicitRole of
                                    Just role ->
                                        Just role

                                    Nothing ->
                                        ImplicitRole.implicitRole fnName attrInfo.knownAttributes
                        in
                        case effectiveRole of
                            Just role ->
                                if NamingProhibition.namingProhibited role then
                                    [ ariaLabelError fnName role (attrInfo.explicitRole /= Nothing) ariaAttrName ariaAttrNameNode ]

                                else
                                    []

                            Nothing ->
                                []

                    Nothing ->
                        []

            _ ->
                []

    else
        []


type alias AttrInfo =
    { ariaLabelNode : Maybe ( String, Node Expression )
    , explicitRole : Maybe String
    , knownAttributes : Dict String String
    }


emptyAttrInfo : AttrInfo
emptyAttrInfo =
    { ariaLabelNode = Nothing
    , explicitRole = Nothing
    , knownAttributes = Dict.empty
    }


extractAttrInfo : Context -> List (Node Expression) -> AttrInfo
extractAttrInfo context items =
    List.foldl (extractSingleAttr context) emptyAttrInfo items


extractSingleAttr : Context -> Node Expression -> AttrInfo -> AttrInfo
extractSingleAttr context node info =
    case Node.value node of
        -- Html.Attributes.attribute "aria-label" "value"
        -- Html.Attributes.attribute "role" "button"
        Expression.Application (fnNode :: firstArg :: restArgs) ->
            case Node.value fnNode of
                Expression.FunctionOrValue _ "attribute" ->
                    let
                        resolved : Maybe (List String)
                        resolved =
                            ModuleNameLookupTable.moduleNameFor context.moduleNameLookupTable fnNode
                    in
                    if isHtmlAttributeModule resolved then
                        case Node.value firstArg of
                            Expression.Literal attrName ->
                                if attrName == "aria-label" || attrName == "aria-labelledby" then
                                    { info | ariaLabelNode = Just ( attrName, firstArg ) }

                                else if attrName == "role" then
                                    case restArgs of
                                        roleValueNode :: _ ->
                                            case Node.value roleValueNode of
                                                Expression.Literal roleValue ->
                                                    { info
                                                        | explicitRole = Just roleValue
                                                        , knownAttributes = Dict.insert "role" roleValue info.knownAttributes
                                                    }

                                                _ ->
                                                    info

                                        _ ->
                                            info

                                else
                                    case restArgs of
                                        valueNode :: _ ->
                                            case Node.value valueNode of
                                                Expression.Literal value ->
                                                    { info | knownAttributes = Dict.insert attrName value info.knownAttributes }

                                                _ ->
                                                    -- Attribute present but value not a literal — record presence
                                                    { info | knownAttributes = Dict.insert attrName "" info.knownAttributes }

                                        _ ->
                                            info

                            _ ->
                                info

                    else
                        info

                -- Html.Attributes.href "/path"
                Expression.FunctionOrValue _ attrFnName ->
                    let
                        resolved : Maybe (List String)
                        resolved =
                            ModuleNameLookupTable.moduleNameFor context.moduleNameLookupTable fnNode
                    in
                    if isHtmlAttributeModule resolved then
                        case restArgs of
                            valueNode :: _ ->
                                case Node.value valueNode of
                                    Expression.Literal value ->
                                        { info | knownAttributes = Dict.insert attrFnName value info.knownAttributes }

                                    _ ->
                                        { info | knownAttributes = Dict.insert attrFnName "" info.knownAttributes }

                            _ ->
                                { info | knownAttributes = Dict.insert attrFnName "" info.knownAttributes }

                    else
                        info

                _ ->
                    info

        -- Partial application: Html.Attributes.href (no argument yet — still records presence)
        Expression.FunctionOrValue _ attrFnName ->
            let
                resolved : Maybe (List String)
                resolved =
                    ModuleNameLookupTable.moduleNameFor context.moduleNameLookupTable node
            in
            if isHtmlAttributeModule resolved && attrFnName /= "attribute" then
                { info | knownAttributes = Dict.insert attrFnName "" info.knownAttributes }

            else
                info

        _ ->
            info


ariaLabelError : String -> String -> Bool -> String -> Node Expression -> Rule.Error {}
ariaLabelError tagName role isExplicit ariaAttrName ariaAttrNameNode =
    let
        roleSource : String
        roleSource =
            if isExplicit then
                "an explicit"

            else
                "an implicit"

        tagSuffix : String
        tagSuffix =
            if tagName == "a" && not isExplicit then
                " without `href`"

            else
                ""
    in
    Rule.error
        { message = "`" ++ ariaAttrName ++ "` has no effect on `<" ++ tagName ++ ">` elements" ++ tagSuffix
        , details =
            [ "The `<" ++ tagName ++ ">` element" ++ tagSuffix ++ " has " ++ roleSource ++ " ARIA role of `" ++ role ++ "`, which prohibits naming from author. The `" ++ ariaAttrName ++ "` attribute will be ignored by assistive technologies."
            , "Either use a semantic HTML element (like `<button>` or `<nav>`) or add an explicit `role` attribute."
            ]
        }
        (Node.range ariaAttrNameNode)


isHtmlElementModule : Maybe (List String) -> Bool
isHtmlElementModule resolvedModule =
    case resolvedModule of
        Just [ "Html" ] ->
            True

        Just [ "Html", "Styled" ] ->
            True

        Just [ "Html", "Keyed" ] ->
            True

        Just [ "Html", "Lazy" ] ->
            True

        Just [ "Html", "Styled", "Keyed" ] ->
            True

        Just [ "Html", "Styled", "Lazy" ] ->
            True

        _ ->
            False



-- HELPERS


isHtmlAttributeModule : Maybe (List String) -> Bool
isHtmlAttributeModule resolvedModule =
    case resolvedModule of
        Just [ "Html", "Attributes" ] ->
            True

        Just [ "Html", "Styled", "Attributes" ] ->
            True

        _ ->
            False


isSvgElementModule : Maybe (List String) -> Bool
isSvgElementModule resolvedModule =
    case resolvedModule of
        Just [ "Svg" ] ->
            True

        Just [ "Svg", "Styled" ] ->
            True

        Just [ "Svg", "Keyed" ] ->
            True

        Just [ "Svg", "Lazy" ] ->
            True

        Just [ "Svg", "Styled", "Keyed" ] ->
            True

        Just [ "Svg", "Styled", "Lazy" ] ->
            True

        _ ->
            False


qualifiedName : List String -> String -> String
qualifiedName moduleName name =
    case moduleName of
        [] ->
            name

        _ ->
            String.join "." moduleName ++ "." ++ name
