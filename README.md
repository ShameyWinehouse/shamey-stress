# shamey-stress

A free, open-source RedM script for a stress mechanic

## Compatibility Disclaimer
This is a relatively simple add-on script for the VORP Framework. However, PLEASE NOTE that this was integrated with an older version of VORP-Metabolism that was highly-customized by me, so this script **will not work** out-of-the-box, but it is a terrific jumping-off point or reference for your own simple stress script.

## Features
- Stress mechanic
  - Stress **increases** at various rates due to:
    - Being in-combat
    - Aiming a dangerous weapon
    - Melee combat
    - Being hogtied
    - Being handcuffed
    - Being armed
  - Stress **decreases** at various rates **only when not in danger** (e.g. combat) when:
    - Walking
    - Standing still (2x)
    - Sitting (4x)
- HUD icon with color states
- Negative consequences for high stress *(semi-random camera shaking, camera flashing, & character ragdolling/collapsing)*
- Job-based immunity *(e.g. gunsmiths)*
- Combat multiplier *(e.g. fighting 3 people at the same time causes a 3x multiplier)*
- Accessibility *(for photosensitive players, one can individually disable the flashing via an item with [shamey-core](https://github.com/ShameyWinehouse/shamey-core))*
- Configurable *(locations, items, buttons, pages)*
- Organized & documented
- Highly performant

## Player Guide: Ways to Destress
- Ensure your character is not in danger. "Danger" here can include having a gun in your hands, being hogtied, etc.
- *(If your server offers de-stressing items)* Consume/carry a de-stressing item.
- Ensure your character is not in-combat. "Combat" is defined by RDR2 itself, and can include aggression with **ANYTHING**, including small animals.
  - A common issue is with wolfpack chases, especially since there can be so many wolves at once. Avoid wolfpack spawn locations, or stay ready.
  - RDR2 itself decides when you're considered "not in combat", so your best bet is to leave the area of your opponent.
- **Don't move.** While you can destress with walking, *staying still* is most effective.
  - Note: Riding on a moving horse/wagon does not count as "still".
- Consider your playstyle. For example, players who spend longer aiming weapons will quickly accrue higher stress than others.

## Notes
### Destressing Items
While stress will go away on its own by safely resting, our server additionally had a cornucopia of items configured (in my customized version of VORP-Metabolism) to destress, like alcohols.

You could also use cigarettes (like in [shamey-doctor](https://github.com/ShameyWinehouse/shamey-doctor)) or even magical amulets (like in [shamey-naturalist](https://github.com/ShameyWinehouse/shamey-naturalist)).

## Requirements
- [VORP Framework](https://github.com/vorpcore)
- [shamey-core](https://github.com/ShameyWinehouse/shamey-core) (for job system and accessibility system)

## License & Support
This software was formerly proprietary to Rainbow Railroad Roleplay, but I am now releasing it free and open-source under GNU GPLv3. I cannot provide any support.