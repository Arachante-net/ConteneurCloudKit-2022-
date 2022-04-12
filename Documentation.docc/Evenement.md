# Événement

Un événement c'est un phénomène qui ce produit dans certaines circonstances.

![Une image](evenement)

## Chapitre

**Super Sloth**: Likes to eat sticks.
__Silly Sloth__: Prefers twigs for breakfast.

A sloth's _metabolism_ is highly dependent on its *habitat*.
If your sloth possesses one of the special powers: `ice`, `fire`, 
`wind`, or `lightning`.
You can increase the sloth's energy level by asking them to 
``eat(_:quantity:)`` or ``sleep(in:for:)``.

Il est ici representé par deux structures : ``Groupe`` et ``Item``



```swift
struct Sightseeing: Activity {
    func perform(with sloth: inout Sloth) -> Speed {
        sloth.energyLevel -= 10
        return .slow
    }
}
```

## Sujet

* Ice
- Fire
* Wind
+ Lightning

1. Give the sloth some food.
2. Take the sloth for a walk.
1. Read the sloth a story.
4. Put the sloth to bed.

- term Ice: Ice sloths thrive below freezing temperatures.

- term Fire: Fire sloths thrive at boiling temperatures.

- term Wind: Wind sloths thrive at soaring altitudes.

- term Lightning: Lightning sloths thrive in stormy climates.


### Quoi ?

- ``Groupe``
- ``Item``

### Comment ?

Sloth speed | Description
--- | ---
`slow` | Moves slightly faster than a snail.
`medium` | Moves at an average speed.
`fast` | Moves faster than a hare.
`supersonic` | Moves faster than the speed of sound.


> Note: General information that applies to some users.

> Important: Important information, such as a requirement.

> Warning: Critical information, like potential data loss or an irrecoverable state.

> Tip: Helpful information, such as shortcuts, suggestions, or hints.

> Experiment: Instructional information to reinforce a learning objective, or to encourage developers to try out different parts of your framework.

