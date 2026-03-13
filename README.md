# elm-review-no-problematic-attributes

Provides [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rules to REPLACEME.

## Provided rules

- [`NoProblematicAttributes`](https://package.elm-lang.org/packages/pete-murphy/elm-review-no-problematic-attributes/1.0.0/NoProblematicAttributes) - Reports REPLACEME.

## Configuration

```elm
module ReviewConfig exposing (config)

import NoProblematicAttributes
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ NoProblematicAttributes.rule
    ]
```

## Try it out

You can try the example configuration above out by running the following command:

```bash
elm-review --template pete-murphy/elm-review-no-problematic-attributes/example
```
