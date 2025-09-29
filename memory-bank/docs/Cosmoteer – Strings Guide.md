# Cosmoteer Strings Authoring Guide

## Required Header
These two declarations must appear at the top of every language file. You only need to add them when creating a brand-new language; appending to an existing locale that already defines them does not require duplicates.

`
__Name = "English"
__DebugOnly = false
`

## File Layout
Strings are organized by sections that mirror the in-game categories. Each section exposes keys and values inside braces.

`
SECTION
{
    Key = "Value"
}
`

### Helpful Layout Tricks
- A backslash (\) outside quotes continues the string on the next line.
- \n inside a string inserts a newline.
- Prefix a path with & to copy the value at that location; use &amp; inside XML-like tags to display a literal ampersand.

## Color Tags
Use color tags to style substrings. Unknown tags (e.g., money, fame) are noted with ?? until verified.

  `
  <color r='255' g='255' b='255' a='127'>Example</color>
  <good>Text</good>          # Rich green
  <green>Text</green>        # Dark green
  <bad>Text</bad>            # Dark red
  <red>Text</red>            # Rich red
  <gray>Text</gray>          # Gray
  <white>Text</white>        # White
  <black>Text</black>        # Black
  <cyan>Text</cyan>          # Cyan
  <magenta>Text</magenta>    # Magenta
  <yellow>Text</yellow>      # Yellow
  <orange>Text</orange>      # Orange
  <money_color>Text</money_color>  # Dark cyan
  <money>Text</money>        # (value TBD)
  <fame>Text</fame>          # (value TBD)
  `

## Formatting Tokens
Placeholder tokens insert runtime values.
- {0} references the first value passed to the string, {1} the second, and so on.
- Append a colon and format specifier for numeric formatting:
  - {0:0.00} forces two decimal places.
  - {1:0.00#} adds an optional third decimal place.
  - {2:n0} formats with thousands separators (e.g., 10000 → 10,000).

## Text Styling Tags
  `
  <b>bold</b>
  <i>italics</i>
  <u>underlined</u>
  <s12>Small text</s12>
  <s24>Large text</s24>   # 12 is standard; 24 is large

  <regular>Neutral</regular>
  <neutral_bright>Neutral bright</neutral_bright>
  <enemy>Enemy</enemy>
  <ally>Ally</ally>
  `

## Image & Icon Inserts
  `
  <img name='sort'/>
  <image name='star_system'/>
  <image name='target'/>
  <image name='categorize'/>
  <img name='objective_normal'/>
  <img name='objective_completed'/>
  <img name='money' colored='true'/>
  <ins_money>{0:n0}</ins_money>
  <image name='command_points' colored='true'/>
  `

## Example Patterns
  `
  <btn id='Game.xxx'/>                # Button reference
  "Contiguous \"Magic Wand\" Selection Mode"  # Escaped quotes
  "\u25CF Bullet point list.\n"           # Unicode bullet with newline
  "<good>✓ Nearest Crew: {0}m</good>"       # Green check mark
  "<bad>✘ No Crew Access</bad>"             # Red cross
  "<yellow>⚠ Nearest {0}: {1}m</yellow>"    # Yellow warning icon
  "<yellow> ⮡ </yellow>"                    # Indented arrow
  "<string id='Resource/SulfurDesc'/>"      # Inline string reference
  `

## Zero-Width Space
Use the Unicode zero-width space (\u200b) to create soft hyphens without visual gaps.

`
Coil2 = "Hyper-\u200bCoil"
Tristeel = "Tri-\u200bSteel"
`

## Copying String Keys
Both copy-references (&Key) and inline <string id='Key'/> references are valid. Choose the approach that best suits the context.

### Method 1: Copy-Reference
Copies the target string verbatim at author time.

`
CommonDescription = "This component is essential for all starships."
StarshipEngineDesc = "The starship engine provides thrust and maneuverability. &CommonDescription"
ShieldGeneratorDesc = "The shield generator protects the starship from incoming attacks. &CommonDescription"
`

### Method 2: Inline Reference
Evaluates the referenced string at runtime and supports nested formatting.

`
WeaponDesc = "This weapon delivers high damage at long range."
LaserCannonDesc = "The Laser Cannon is an advanced weapon system. <string id='WeaponDesc'/>"
`

### Consolidated Workflow
`
CommonDescription = "This component is essential for all starships."
WeaponDesc = "This weapon delivers high damage at long range."

StarshipEngineDesc = "The starship engine provides thrust and maneuverability. <string id='CommonDescription'/>"
ShieldGeneratorDesc = "The shield generator protects the starship from incoming attacks. <string id='CommonDescription'/>"
LaserCannonDesc = "The Laser Cannon is an advanced weapon system. <string id='WeaponDesc'/>"
`

This keeps shared language consistent and easy to maintain.
