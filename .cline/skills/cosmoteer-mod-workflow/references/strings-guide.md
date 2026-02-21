# Cosmoteer Strings Authoring Guide

## Required Header
These declarations must appear at the top of a new language file:

```
__Name = "English"
__DebugOnly = false
```

## File Layout
Strings are organized by sections:

```
SECTION
{
    Key = "Value"
}
```

## Helpful Layout Tricks
- A backslash outside quotes continues the string on the next line.
- `\n` inserts a newline.
- Prefix a path with `&` to copy the value at that location.

## Color Tags
```
<color r='255' g='255' b='255' a='127'>Example</color>
<good>Text</good>
<green>Text</green>
<bad>Text</bad>
<red>Text</red>
<gray>Text</gray>
<white>Text</white>
<black>Text</black>
<cyan>Text</cyan>
<magenta>Text</magenta>
<yellow>Text</yellow>
<orange>Text</orange>
<money_color>Text</money_color>
```

## Formatting Tokens
- `{0}` references the first value, `{1}` the second, etc.
- Format specifiers:
  - `{0:0.00}` forces two decimal places.
  - `{1:0.00#}` allows an optional third decimal place.
  - `{2:n0}` adds thousands separators.

## Text Styling Tags
```
<b>bold</b>
<i>italics</i>
<u>underlined</u>
<s12>Small text</s12>
<s24>Large text</s24>

<regular>Neutral</regular>
<neutral_bright>Neutral bright</neutral_bright>
<enemy>Enemy</enemy>
<ally>Ally</ally>
```

## Image and Icon Inserts
```
<img name='sort'/>
<image name='star_system'/>
<image name='target'/>
<img name='objective_normal'/>
<img name='objective_completed'/>
<img name='money' colored='true'/>
<ins_money>{0:n0}</ins_money>
<image name='command_points' colored='true'/>
```

## Example Patterns
```
<btn id='Game.xxx'/>
"Contiguous \"Magic Wand\" Selection Mode"
"\u25CF Bullet point list.\n"
"<good>OK: Nearest Crew: {0}m</good>"
"<bad>NO: No Crew Access</bad>"
"<yellow>WARN: Nearest {0}: {1}m</yellow>"
"<string id='Resource/SulfurDesc'/>"
```

## Zero-Width Space
Use `\u200b` to create soft hyphens without visible gaps.

```
Coil2 = "Hyper-\u200bCoil"
Tristeel = "Tri-\u200bSteel"
```

## Copying String Keys
Two valid approaches:

Method 1: Copy-reference (author time)
```
CommonDescription = "This component is essential."
WeaponDesc = "Advanced weapon system. &CommonDescription"
```

Method 2: Inline reference (runtime)
```
CommonDescription = "This component is essential."
WeaponDesc = "Advanced weapon system. <string id='CommonDescription'/>"
```
