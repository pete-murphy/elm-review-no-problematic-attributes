module NoProblematicAttributesTest exposing (all)

import NoProblematicAttributes
import Review.Project as Project exposing (Project)
import Review.Rule exposing (Rule)
import Review.Test
import Review.Test.Dependencies
import Test exposing (Test, describe, test)


rule : Rule
rule =
    NoProblematicAttributes.rule NoProblematicAttributes.defaults


projectWithHtmlDependency : Project
projectWithHtmlDependency =
    Project.new
        |> Project.addDependency Review.Test.Dependencies.elmHtml


all : Test
all =
    describe "NoProblematicAttributes"
        [ xlinkTests
        , svgStyleTests
        , titleTests
        , htmlClassOnSvgTests
        , customOptionTests
        , ariaLabelTests
        ]



-- REQUIREMENT 1: xlink:* attributes


xlinkTests : Test
xlinkTests =
    describe "xlink:* attributes"
        [ test "should not report non-xlink SVG attributes" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes
a = Svg.Attributes.fill "red"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should report Svg.Attributes.xlinkHref and fix it" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes
a = Svg.Attributes.xlinkHref "#icon"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Attributes.xlinkHref`"
                            , details =
                                [ "`xlink:href` is deprecated in SVG 2.0 and causes rendering problems with Elm's virtual DOM."
                                , "Use `Html.Attributes.attribute \"href\" \"...\"` instead. Note: don't use `Html.Attributes.href` since that sets the `.href` property, which is readonly in SVG."
                                ]
                            , under = "Svg.Attributes.xlinkHref"
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
import Svg.Attributes
a = Html.Attributes.attribute "href" "#icon"
"""
                        ]
        , test "should report Svg.Attributes.xlinkActuate" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes
a = Svg.Attributes.xlinkActuate "onLoad"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Attributes.xlinkActuate`"
                            , details =
                                [ "All `xlink:*` attributes are deprecated in SVG 2.0 and cause rendering problems with Elm's virtual DOM."
                                , "See https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/xlink:href for more information."
                                ]
                            , under = "Svg.Attributes.xlinkActuate"
                            }
                        ]
        , test "should report Svg.Attributes.xlinkArcrole" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes
a = Svg.Attributes.xlinkArcrole ""
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Attributes.xlinkArcrole`"
                            , details =
                                [ "All `xlink:*` attributes are deprecated in SVG 2.0 and cause rendering problems with Elm's virtual DOM."
                                , "See https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/xlink:href for more information."
                                ]
                            , under = "Svg.Attributes.xlinkArcrole"
                            }
                        ]
        , test "should report Svg.Attributes.xlinkRole" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes
a = Svg.Attributes.xlinkRole ""
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Attributes.xlinkRole`"
                            , details =
                                [ "All `xlink:*` attributes are deprecated in SVG 2.0 and cause rendering problems with Elm's virtual DOM."
                                , "See https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/xlink:href for more information."
                                ]
                            , under = "Svg.Attributes.xlinkRole"
                            }
                        ]
        , test "should report Svg.Attributes.xlinkShow" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes
a = Svg.Attributes.xlinkShow ""
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Attributes.xlinkShow`"
                            , details =
                                [ "All `xlink:*` attributes are deprecated in SVG 2.0 and cause rendering problems with Elm's virtual DOM."
                                , "See https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/xlink:href for more information."
                                ]
                            , under = "Svg.Attributes.xlinkShow"
                            }
                        ]
        , test "should report Svg.Attributes.xlinkTitle" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes
a = Svg.Attributes.xlinkTitle ""
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Attributes.xlinkTitle`"
                            , details =
                                [ "All `xlink:*` attributes are deprecated in SVG 2.0 and cause rendering problems with Elm's virtual DOM."
                                , "See https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/xlink:href for more information."
                                ]
                            , under = "Svg.Attributes.xlinkTitle"
                            }
                        ]
        , test "should report Svg.Attributes.xlinkType" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes
a = Svg.Attributes.xlinkType ""
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Attributes.xlinkType`"
                            , details =
                                [ "All `xlink:*` attributes are deprecated in SVG 2.0 and cause rendering problems with Elm's virtual DOM."
                                , "See https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/xlink:href for more information."
                                ]
                            , under = "Svg.Attributes.xlinkType"
                            }
                        ]
        , test "should report aliased Svg.Attributes xlinkHref and fix it" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes as SA
a = SA.xlinkHref "#icon"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Attributes.xlinkHref`"
                            , details =
                                [ "`xlink:href` is deprecated in SVG 2.0 and causes rendering problems with Elm's virtual DOM."
                                , "Use `Html.Attributes.attribute \"href\" \"...\"` instead. Note: don't use `Html.Attributes.href` since that sets the `.href` property, which is readonly in SVG."
                                ]
                            , under = "SA.xlinkHref"
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
import Svg.Attributes as SA
a = Html.Attributes.attribute "href" "#icon"
"""
                        ]
        , test "should report Svg.Styled.Attributes.xlinkHref and fix it" <|
            \() ->
                """module A exposing (..)
import Svg.Styled.Attributes
a = Svg.Styled.Attributes.xlinkHref "#icon"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Styled.Attributes.xlinkHref`"
                            , details =
                                [ "`xlink:href` is deprecated in SVG 2.0 and causes rendering problems with Elm's virtual DOM."
                                , "Use `Html.Attributes.attribute \"href\" \"...\"` instead. Note: don't use `Html.Attributes.href` since that sets the `.href` property, which is readonly in SVG."
                                ]
                            , under = "Svg.Styled.Attributes.xlinkHref"
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
import Svg.Styled.Attributes
a = Html.Attributes.attribute "href" "#icon"
"""
                        ]
        , test "should not report xlinkHref from a different module" <|
            \() ->
                """module A exposing (..)
import MyModule
a = MyModule.xlinkHref "#icon"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]



-- REQUIREMENT 3: SVG inline style


svgStyleTests : Test
svgStyleTests =
    describe "SVG inline style"
        [ test "should not report Html.Attributes.style" <|
            \() ->
                """module A exposing (..)
import Html.Attributes
a = Html.Attributes.style "color" "red"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should report Svg.Attributes.style" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes
a = Svg.Attributes.style "color" "red"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Attributes.style`"
                            , details =
                                [ "Inline style attributes are incompatible with Content Security Policy without `style-src 'unsafe-inline'`."
                                , "Use class-based styling instead."
                                ]
                            , under = "Svg.Attributes.style"
                            }
                        ]
        , test "should report Svg.Styled.Attributes.style" <|
            \() ->
                """module A exposing (..)
import Svg.Styled.Attributes
a = Svg.Styled.Attributes.style "color" "red"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Styled.Attributes.style`"
                            , details =
                                [ "Inline style attributes are incompatible with Content Security Policy without `style-src 'unsafe-inline'`."
                                , "Use class-based styling instead."
                                ]
                            , under = "Svg.Styled.Attributes.style"
                            }
                        ]
        , test "should report aliased Svg.Attributes.style" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes as SA
a = SA.style "color" "red"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Svg.Attributes.style`"
                            , details =
                                [ "Inline style attributes are incompatible with Content Security Policy without `style-src 'unsafe-inline'`."
                                , "Use class-based styling instead."
                                ]
                            , under = "SA.style"
                            }
                        ]
        , test "should not report style from a different module" <|
            \() ->
                """module A exposing (..)
import MyModule
a = MyModule.style "color" "red"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]



-- REQUIREMENT 4: title attribute


titleTests : Test
titleTests =
    describe "title attribute"
        [ test "should report Html.Attributes.title" <|
            \() ->
                """module A exposing (..)
import Html.Attributes
a = Html.Attributes.title "tooltip"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use the `Html.Attributes.title` attribute"
                            , details =
                                [ "The `title` attribute is discouraged because many user agents do not expose it accessibly. It typically requires a pointing device (mouse) to trigger a tooltip, excluding keyboard-only and touch-only users."
                                , "See https://html.spec.whatwg.org/multipage/dom.html#the-title-attribute for more information."
                                ]
                            , under = "Html.Attributes.title"
                            }
                        ]
        , test "should report Html.Styled.Attributes.title" <|
            \() ->
                """module A exposing (..)
import Html.Styled.Attributes
a = Html.Styled.Attributes.title "tooltip"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use the `Html.Styled.Attributes.title` attribute"
                            , details =
                                [ "The `title` attribute is discouraged because many user agents do not expose it accessibly. It typically requires a pointing device (mouse) to trigger a tooltip, excluding keyboard-only and touch-only users."
                                , "See https://html.spec.whatwg.org/multipage/dom.html#the-title-attribute for more information."
                                ]
                            , under = "Html.Styled.Attributes.title"
                            }
                        ]
        , test "should report aliased Html.Attributes.title" <|
            \() ->
                """module A exposing (..)
import Html.Attributes as HA
a = HA.title "tooltip"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use the `Html.Attributes.title` attribute"
                            , details =
                                [ "The `title` attribute is discouraged because many user agents do not expose it accessibly. It typically requires a pointing device (mouse) to trigger a tooltip, excluding keyboard-only and touch-only users."
                                , "See https://html.spec.whatwg.org/multipage/dom.html#the-title-attribute for more information."
                                ]
                            , under = "HA.title"
                            }
                        ]
        , test "should not report Svg.Attributes.title" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes
a = Svg.Attributes.title "my title"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should not report title from a different module" <|
            \() ->
                """module A exposing (..)
import MyModule
a = MyModule.title "tooltip"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]



-- REQUIREMENT 2: Html.Attributes.class on SVG elements


htmlClassOnSvgTests : Test
htmlClassOnSvgTests =
    describe "Html.Attributes.class on SVG elements"
        [ test "should not report Html.Attributes.class on HTML elements" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.div [ Html.Attributes.class "foo" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency rule
                    |> Review.Test.expectNoErrors
        , test "should report Html.Attributes.class in Svg element attribute list and fix it" <|
            \() ->
                """module A exposing (..)
import Html.Attributes
import Svg
a = Svg.svg [ Html.Attributes.class "icon" ] []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Html.Attributes.class` on SVG elements"
                            , details =
                                [ "Using `Html.Attributes.class` on SVG elements causes a runtime error: \"Cannot set property className of #<SVGElement> which has only a getter\"."
                                , "Use `Svg.Attributes.class` instead."
                                ]
                            , under = "Html.Attributes.class"
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
import Html.Attributes
import Svg
a = Svg.svg [ Svg.Attributes.class "icon" ] []
"""
                        ]
        , test "should report Html.Attributes.class in Svg.circle attribute list and fix it" <|
            \() ->
                """module A exposing (..)
import Html.Attributes
import Svg
a = Svg.circle [ Html.Attributes.class "dot" ] []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Html.Attributes.class` on SVG elements"
                            , details =
                                [ "Using `Html.Attributes.class` on SVG elements causes a runtime error: \"Cannot set property className of #<SVGElement> which has only a getter\"."
                                , "Use `Svg.Attributes.class` instead."
                                ]
                            , under = "Html.Attributes.class"
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
import Html.Attributes
import Svg
a = Svg.circle [ Svg.Attributes.class "dot" ] []
"""
                        ]
        , test "should not report Svg.Attributes.class on SVG elements" <|
            \() ->
                """module A exposing (..)
import Svg
import Svg.Attributes
a = Svg.svg [ Svg.Attributes.class "icon" ] []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should report Html.Styled.Attributes.class on Svg.Styled elements and fix it" <|
            \() ->
                """module A exposing (..)
import Html.Styled.Attributes
import Svg.Styled
a = Svg.Styled.svg [ Html.Styled.Attributes.class "icon" ] []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `Html.Styled.Attributes.class` on SVG elements"
                            , details =
                                [ "Using `Html.Attributes.class` on SVG elements causes a runtime error: \"Cannot set property className of #<SVGElement> which has only a getter\"."
                                , "Use `Svg.Attributes.class` instead."
                                ]
                            , under = "Html.Styled.Attributes.class"
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
import Html.Styled.Attributes
import Svg.Styled
a = Svg.Styled.svg [ Svg.Attributes.class "icon" ] []
"""
                        ]
        , test "should report aliased Html.Attributes.class on SVG elements and fix it" <|
            \() ->
                """module A exposing (..)
import Html.Attributes as HA
import Svg
a = Svg.svg [ HA.class "icon" ] []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use `HA.class` on SVG elements"
                            , details =
                                [ "Using `Html.Attributes.class` on SVG elements causes a runtime error: \"Cannot set property className of #<SVGElement> which has only a getter\"."
                                , "Use `Svg.Attributes.class` instead."
                                ]
                            , under = "HA.class"
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
import Html.Attributes as HA
import Svg
a = Svg.svg [ Svg.Attributes.class "icon" ] []
"""
                        ]
        , test "should not report when attribute list is a variable" <|
            \() ->
                """module A exposing (..)
import Svg
a attrs = Svg.svg attrs []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]



-- Custom options


customOptionTests : Test
customOptionTests =
    describe "custom options"
        [ test "should report a custom forbidden function" <|
            \() ->
                """module A exposing (..)
import Html.Attributes
a = Html.Attributes.contenteditable True
"""
                    |> Review.Test.run
                        (NoProblematicAttributes.rule
                            [ NoProblematicAttributes.forbid
                                { moduleName = [ "Html", "Attributes" ]
                                , functionName = "contenteditable"
                                , message = "Don't use contenteditable"
                                , details = [ "It causes issues." ]
                                }
                            ]
                        )
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use contenteditable"
                            , details = [ "It causes issues." ]
                            , under = "Html.Attributes.contenteditable"
                            }
                        ]
        , test "should report a custom forbidden function with fix" <|
            \() ->
                """module A exposing (..)
import Html.Attributes
a = Html.Attributes.contenteditable True
"""
                    |> Review.Test.run
                        (NoProblematicAttributes.rule
                            [ NoProblematicAttributes.forbidWithFix
                                { moduleName = [ "Html", "Attributes" ]
                                , functionName = "contenteditable"
                                , message = "Don't use contenteditable"
                                , details = [ "Use our custom version." ]
                                , replaceWith = "CustomAttributes.contenteditable"
                                }
                            ]
                        )
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Don't use contenteditable"
                            , details = [ "Use our custom version." ]
                            , under = "Html.Attributes.contenteditable"
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
import Html.Attributes
a = CustomAttributes.contenteditable True
"""
                        ]
        , test "should not report defaults when using custom-only options" <|
            \() ->
                """module A exposing (..)
import Svg.Attributes
a = Svg.Attributes.xlinkHref "#icon"
"""
                    |> Review.Test.run
                        (NoProblematicAttributes.rule
                            [ NoProblematicAttributes.forbid
                                { moduleName = [ "Html", "Attributes" ]
                                , functionName = "contenteditable"
                                , message = "Don't use contenteditable"
                                , details = [ "It causes issues." ]
                                }
                            ]
                        )
                    |> Review.Test.expectNoErrors
        ]



-- REQUIREMENT 5: aria-label on naming-prohibited elements


ariaLabelRule : Rule
ariaLabelRule =
    NoProblematicAttributes.rule [ NoProblematicAttributes.noAriaLabelOnNamingProhibited ]


ariaLabelTests : Test
ariaLabelTests =
    describe "aria-label on naming-prohibited elements"
        [ test "should report aria-label on div (implicit role=generic)" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.div [ Html.Attributes.attribute "aria-label" "foo" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`aria-label` has no effect on `<div>` elements"
                            , details =
                                [ "The `<div>` element has an implicit ARIA role of `generic`, which prohibits naming from author. The `aria-label` attribute will be ignored by assistive technologies."
                                , "Either use a semantic HTML element (like `<button>` or `<nav>`) or add an explicit `role` attribute."
                                ]
                            , under = "\"aria-label\""
                            }
                        ]
        , test "should report aria-label on span (implicit role=generic)" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.span [ Html.Attributes.attribute "aria-label" "bar" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`aria-label` has no effect on `<span>` elements"
                            , details =
                                [ "The `<span>` element has an implicit ARIA role of `generic`, which prohibits naming from author. The `aria-label` attribute will be ignored by assistive technologies."
                                , "Either use a semantic HTML element (like `<button>` or `<nav>`) or add an explicit `role` attribute."
                                ]
                            , under = "\"aria-label\""
                            }
                        ]
        , test "should not report aria-label on button (naming allowed)" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.button [ Html.Attributes.attribute "aria-label" "Close" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectNoErrors
        , test "should not report aria-label on nav (naming allowed)" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.nav [ Html.Attributes.attribute "aria-label" "Main" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectNoErrors
        , test "should not report when div has explicit role=button" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.div [ Html.Attributes.attribute "role" "button", Html.Attributes.attribute "aria-label" "Close" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectNoErrors
        , test "should report when div has explicit role=generic" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.div [ Html.Attributes.attribute "role" "generic", Html.Attributes.attribute "aria-label" "foo" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`aria-label` has no effect on `<div>` elements"
                            , details =
                                [ "The `<div>` element has an explicit ARIA role of `generic`, which prohibits naming from author. The `aria-label` attribute will be ignored by assistive technologies."
                                , "Either use a semantic HTML element (like `<button>` or `<nav>`) or add an explicit `role` attribute."
                                ]
                            , under = "\"aria-label\""
                            }
                        ]
        , test "should report aria-labelledby on span" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.span [ Html.Attributes.attribute "aria-labelledby" "some-id" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`aria-labelledby` has no effect on `<span>` elements"
                            , details =
                                [ "The `<span>` element has an implicit ARIA role of `generic`, which prohibits naming from author. The `aria-labelledby` attribute will be ignored by assistive technologies."
                                , "Either use a semantic HTML element (like `<button>` or `<nav>`) or add an explicit `role` attribute."
                                ]
                            , under = "\"aria-labelledby\""
                            }
                        ]
        , test "should not report when no aria-label is present" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.div [ Html.Attributes.class "foo" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectNoErrors
        , test "should not report when attribute list is a variable" <|
            \() ->
                """module A exposing (..)
import Html
a attrs = Html.div attrs []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectNoErrors
        , test "should not report for non-Html module functions" <|
            \() ->
                """module A exposing (..)
import Html.Attributes
a = MyComponent.div [ Html.Attributes.attribute "aria-label" "x" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectNoErrors
        , test "should not report aria-label on a with href (role=link)" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.a [ Html.Attributes.href "/", Html.Attributes.attribute "aria-label" "Home" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectNoErrors
        , test "should report aria-label on a without href (role=generic)" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.a [ Html.Attributes.attribute "aria-label" "foo" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`aria-label` has no effect on `<a>` elements without `href`"
                            , details =
                                [ "The `<a>` element without `href` has an implicit ARIA role of `generic`, which prohibits naming from author. The `aria-label` attribute will be ignored by assistive technologies."
                                , "Either use a semantic HTML element (like `<button>` or `<nav>`) or add an explicit `role` attribute."
                                ]
                            , under = "\"aria-label\""
                            }
                        ]
        , test "should report aria-label on p (role=paragraph, naming prohibited)" <|
            \() ->
                """module A exposing (..)
import Html
import Html.Attributes
a = Html.p [ Html.Attributes.attribute "aria-label" "foo" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`aria-label` has no effect on `<p>` elements"
                            , details =
                                [ "The `<p>` element has an implicit ARIA role of `paragraph`, which prohibits naming from author. The `aria-label` attribute will be ignored by assistive technologies."
                                , "Either use a semantic HTML element (like `<button>` or `<nav>`) or add an explicit `role` attribute."
                                ]
                            , under = "\"aria-label\""
                            }
                        ]
        , test "should work with aliased Html module" <|
            \() ->
                """module A exposing (..)
import Html as H
import Html.Attributes as HA
a = H.div [ HA.attribute "aria-label" "foo" ] []
"""
                    |> Review.Test.runWithProjectData projectWithHtmlDependency ariaLabelRule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`aria-label` has no effect on `<div>` elements"
                            , details =
                                [ "The `<div>` element has an implicit ARIA role of `generic`, which prohibits naming from author. The `aria-label` attribute will be ignored by assistive technologies."
                                , "Either use a semantic HTML element (like `<button>` or `<nav>`) or add an explicit `role` attribute."
                                ]
                            , under = "\"aria-label\""
                            }
                        ]
        ]
