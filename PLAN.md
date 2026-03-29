This repo is for an `elm-review` rule that will ban "problematic" HTML attributes.

## Requirements

Support `elm/html` as well as `rtfeldman/elm-css`.

1. Don't use `xlink:href` (https://github.com/elm/svg/issues/31, https://github.com/elm/virtual-dom/issues/62).

Causes rendering problems.

> To those who run into this: The easiest way to solve the problem with `xlink:href` these days is to switch to just `href` instead. `xlink:href` is deprected: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/xlink:href. `href` has great browser compatibility: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/href#browser_compatibility
>
> ```diff
> -Svg.Attributes.xlinkHref "my-url"
> +Html.Attributes.attribute "href" "my-url"
> ```
>
> Note: Don’t use `Html.Attributes.href` since that is implemented by setting the `.href` property, which is readonly in SVG – only the `href` _attribute_ can be set.
>
> However, all `Svg.Attributes.xlink*` functions (not just `Svg.Attributes.xlinkHref`) suffer from this issue, and for the rest I don’t know the solution (I’ve never used any of them). But in that case https://github.com/elm/virtual-dom/pull/159 seems to be a correct PR.
>
> It appears that _all_ `xlink:*` attributes are deprecated, and that’s discussed in: https://github.com/elm/svg/issues/22

2. Don't use `Html.Attributes.class` on SVG elements (https://github.com/elm/svg/issues/3).

Leads to runtime error (`Uncaught TypeError: Cannot set property className of #<SVGElement> which has only a getter`). Use `Svg.Attributes.class` instead.

3. No inline SVG `style` attribute (incompatible with Content-Security-Policy without use of `unsafe-` directives)

```elm
module NoInlineSvgStyleAttribute exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Review.ModuleNameLookupTable as ModuleNameLookupTable exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Rule)


{-| Reports errors when using inline SVG style attribute.

    config =
        [ NoInlineSvgStyleAttribute.rule
        ]


## Fail

    import Svg.Styled as Svg exposing (Svg)
    import Svg.Styled.Attributes

    view : Svg msg
    view =
        Svg.svg [ Svg.Styled.Attributes.style "color: red;" ] []


## Success

    import Svg.Styled as Svg exposing (Svg)
    import Svg.Styled.Attributes

    view : Svg msg
    view =
        Svg.svg [] []

-}
rule : Rule
rule =
    Rule.newModuleRuleSchemaUsingContextCreator "NoInlineSvgStyleAttribute" initialContext
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    { moduleNameLookupTable : ModuleNameLookupTable }


initialContext : Rule.ContextCreator () Context
initialContext =
    Rule.initContextCreator
        (\moduleNameLookupTable () ->
            { moduleNameLookupTable = moduleNameLookupTable }
        )
        |> Rule.withModuleNameLookupTable


expressionVisitor : Node Expression -> Context -> ( List (Rule.Error {}), Context )
expressionVisitor node context =
    case Node.value node of
        Expression.FunctionOrValue moduleName "style" ->
            let
                resolvedModuleName =
                    ModuleNameLookupTable.moduleNameFor context.moduleNameLookupTable node

                fullFunctionName name =
                    case ( moduleName, resolvedModuleName ) of
                        ( [], Just resolved ) ->
                            String.join "." (resolved ++ [ name ])

                        _ ->
                            String.join "." (moduleName ++ [ name ])
            in
            if resolvedModuleName == Just [ "Svg", "Styled", "Attributes" ] || resolvedModuleName == Just [ "Svg", "Attributes" ] then
                ( [ Rule.error
                        { message = "Don't use `" ++ fullFunctionName "style" ++ "`, replace with `" ++ fullFunctionName "class" ++ "` if possible"
                        , details = [ "Inline style attribute is incompatible with Content Security Policy without \"style-src 'unsafe-inline'\"." ]
                        }
                        (Node.range node)
                  ]
                , context
                )

            else
                ( [], context )

        _ ->
            ( [], context )
```

4. `title` attribute (https://html.spec.whatwg.org/multipage/dom.html#the-title-attribute)

> Relying on the `title` attribute is currently discouraged as many user agents do not expose the attribute in an accessible manner as required by this specification (e.g., requiring a pointing device such as a mouse to cause a tooltip to appear, which excludes keyboard-only users and touch-only users, such as anyone with a modern phone or tablet).

5. Use of `aria-label` on elements that don't permit name from author (such as `<div>` or `<span>` without `role`)

This one is trickier to implement because you'd need to resolve the `role`. In the cases where it's not statically known, err on the side of permitting `aria-label`.
