module NoProblematicAttributes exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Review.Fix as Fix
import Review.ModuleNameLookupTable as ModuleNameLookupTable exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Rule)


{-| Reports uses of problematic HTML and SVG attributes.

    config =
        [ NoProblematicAttributes.rule
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
rule : Rule
rule =
    Rule.newModuleRuleSchemaUsingContextCreator "NoProblematicAttributes" initialContext
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


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


expressionVisitor : Node Expression -> Context -> ( List (Rule.Error {}), Context )
expressionVisitor node context =
    case Node.value node of
        Expression.FunctionOrValue moduleName name ->
            ( checkFunctionOrValue node moduleName name context
            , context
            )

        Expression.Application (fnNode :: attrListNode :: _) ->
            case Node.value fnNode of
                Expression.FunctionOrValue _ _ ->
                    ( checkSvgApplication fnNode attrListNode context
                    , context
                    )

                _ ->
                    ( [], context )

        _ ->
            ( [], context )



-- CATEGORY A: Always-banned attributes


checkFunctionOrValue : Node Expression -> List String -> String -> Context -> List (Rule.Error {})
checkFunctionOrValue node moduleName name context =
    let
        resolvedModule : Maybe (List String)
        resolvedModule =
            ModuleNameLookupTable.moduleNameFor context.moduleNameLookupTable node
    in
    if isXlinkFunction name && isSvgAttributeModule resolvedModule then
        [ xlinkError moduleName name node ]

    else if name == "style" && isSvgAttributeModule resolvedModule then
        [ svgStyleError moduleName node ]

    else if name == "title" && isHtmlAttributeModule resolvedModule then
        [ titleError moduleName node ]

    else
        []


isXlinkFunction : String -> Bool
isXlinkFunction name =
    case name of
        "xlinkActuate" ->
            True

        "xlinkArcrole" ->
            True

        "xlinkHref" ->
            True

        "xlinkRole" ->
            True

        "xlinkShow" ->
            True

        "xlinkTitle" ->
            True

        "xlinkType" ->
            True

        _ ->
            False


xlinkError : List String -> String -> Node Expression -> Rule.Error {}
xlinkError moduleName name node =
    let
        qualName : String
        qualName =
            qualifiedName moduleName name
    in
    if name == "xlinkHref" then
        Rule.errorWithFix
            { message = "Don't use `" ++ qualName ++ "`"
            , details =
                [ "`xlink:href` is deprecated in SVG 2.0 and causes rendering problems with Elm's virtual DOM."
                , "Use `Html.Attributes.attribute \"href\" \"...\"` instead. Note: don't use `Html.Attributes.href` since that sets the `.href` property, which is readonly in SVG."
                ]
            }
            (Node.range node)
            [ Fix.replaceRangeBy (Node.range node) "Html.Attributes.attribute \"href\"" ]

    else
        Rule.error
            { message = "Don't use `" ++ qualName ++ "`"
            , details =
                [ "All `xlink:*` attributes are deprecated in SVG 2.0 and cause rendering problems with Elm's virtual DOM."
                , "See https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/xlink:href for more information."
                ]
            }
            (Node.range node)


svgStyleError : List String -> Node Expression -> Rule.Error {}
svgStyleError moduleName node =
    Rule.error
        { message = "Don't use `" ++ qualifiedName moduleName "style" ++ "`"
        , details =
            [ "Inline style attributes are incompatible with Content Security Policy without `style-src 'unsafe-inline'`."
            , "Use class-based styling instead."
            ]
        }
        (Node.range node)


titleError : List String -> Node Expression -> Rule.Error {}
titleError moduleName node =
    Rule.error
        { message = "Don't use the `" ++ qualifiedName moduleName "title" ++ "` attribute"
        , details =
            [ "The `title` attribute is discouraged because many user agents do not expose it accessibly. It typically requires a pointing device (mouse) to trigger a tooltip, excluding keyboard-only and touch-only users."
            , "See https://html.spec.whatwg.org/multipage/dom.html#the-title-attribute for more information."
            ]
        }
        (Node.range node)



-- CATEGORY B: Context-dependent checks


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
                Just
                    (htmlClassOnSvgError moduleName node)

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
                        Just
                            (htmlClassOnSvgError moduleName innerNode)

                    else
                        Nothing

                _ ->
                    Nothing

        _ ->
            Nothing


htmlClassOnSvgError : List String -> Node Expression -> Rule.Error {}
htmlClassOnSvgError moduleName node =
    Rule.errorWithFix
        { message = "Don't use `" ++ qualifiedName moduleName "class" ++ "` on SVG elements"
        , details =
            [ "Using `Html.Attributes.class` on SVG elements causes a runtime error: \"Cannot set property className of #<SVGElement> which has only a getter\"."
            , "Use `Svg.Attributes.class` instead."
            ]
        }
        (Node.range node)
        [ Fix.replaceRangeBy (Node.range node) "Svg.Attributes.class" ]



-- HELPERS


isSvgAttributeModule : Maybe (List String) -> Bool
isSvgAttributeModule resolvedModule =
    case resolvedModule of
        Just [ "Svg", "Attributes" ] ->
            True

        Just [ "Svg", "Styled", "Attributes" ] ->
            True

        _ ->
            False


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
