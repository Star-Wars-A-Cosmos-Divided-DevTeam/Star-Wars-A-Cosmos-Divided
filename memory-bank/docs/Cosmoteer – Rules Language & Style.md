---
name: Cosmoteer – Rules Language & Style
globs: ["**/*.rules"]
description: Local style and safety checks for SWACD `.rules` changes.
---

# Rules Language – Style & Safety Checks

When proposing `.rules` changes:

1. **Inheritance & Referencing**
   - Confirm parent object paths exist (open parent file to verify).
   - Avoid copy–paste bloat; prefer inheritance with clear overrides.
   - Paths in Cosmoteer work similarly to operating system file paths but have added complexity to allow mod flexibility.

    Example Path: ./Data/ships/terran/armor/icon.png //This refers to a main game file (not in this mod)

- Note: Quotation marks are used around paths in certain cases:
- When referencing a file path directly in .rules files (e.g., NormalsFile = "silver_normals.png").
- When the path contains special characters or spaces to prevent parsing errors.
- As a general best practice, especially in complex modding scenarios, even if not strictly necessary.

    ### 1.1 Path Components and Notation

    - &: Indicates that the path is within a .rules file.
    - <>: Used to encapsulate regular file paths.
    - {}: Denotes a node within a file.
    - []: Denotes a list within a file, where unnamed nodes are referenced by index (starting at 0).
    - ~: When preceeding a path indicates that is should perform a value copy of whatever its pointing to.  E.g., it goes to the path and copies whatever its pointing to.

    ### 1.1a Special Path Notations

    - ./: Start at the top level of the game’s data files.
    - ../: Move up one level from the current node or file.
    - ~/: Start at the top of the current rules file.
    - ^/: Reference data inherited from another node (useful for non-list data).

    #### 1.2 Substitution and Code References
    ### 1.2a Ampersand (&) Usage

    - The ampersand (&) is used to copy the data at the specified path. This is known as a copy-reference.
    - Without the ampersand, the path acts as an actual reference to the object, which creates a link to the object rather than copying it.

    ### 1.2b Copy-Reference vs. Actual Reference

    - Copy-Reference (&):

    - The data is copied from the referenced location into your file.
    - Analogy: Like copy-pasting a Wikipedia article into a Word document—if the original article changes, your copy remains the same.
    - Actual Reference (No &):
    - Creates a dynamic link to the original object, meaning changes to the original will be reflected wherever it’s referenced.
    - Analogy: Like copy-pasting the URL of a Wikipedia article into a document—if the article changes, the contents viewed via the link will also change.

    ### 1.2c Example

    - Copy-Reference: &<super_armor/super_armor.rules>/Part
    - This copies the data from the specified path.
    - Actual Reference: <super_armor/super_armor.rules>/Part
    - This creates a link to the specified object.

    #### 1.3 Inheritance in Cosmoteer

    ### 1.3a Inheritance Syntax

    - :: Inheritance operation. Creates a new node by inheriting properties from another node and allows modifications.
    - {}: Required after the colon to specify the list of changes, even if empty.

    ### 1.3b Example of Inheritance Error

    - Issue: Missing curly brackets after an inheritance operation.
    - Fix: Add {} after the colon or replace : with = to correct the syntax.

    #### 1.4 Common Path Syntax Examples

    - Setting a stack size:
    - MaxStackSize = (&<./Data/resources/carbon/carbon.rules>/MaxStackSize)
    - Referencing a file:
    - NormalsFile = "silver_normals.png"

2. **Components & Graphics**
   - Ensure `Graphics`, `Effects`, `Locations`, `SituationCode`, `PhysRect`, etc., align with part size and rotation.
   - Re-check `RenderLayer` & `Z` ordering if sprites fail to show.
3. **Strings & localization**
   - If changing `NameKey`/`DescriptionKey`, ensure entries are under `strings/`.
4. **Assets**
   - Match sprite paths and dimensions. Keep icon guidelines consistent.
5. **Testing**
   - Load the mod with only the necessary mods enabled first. Check log for missing references.

Provide **minimal diffs** like:

```diff
Replace this
-  Graphics: {}
With this
  		Graphics
		{
			Type = Graphics
			Location = [0.5, 0.5]
			Floor // This is a comment
           /* This is a multi
           line comment */
			{
				Layer = "floors"
				DamageLevels
				[
					{
						File = "armor.png"
						Size = [1, 1]
						UVRotation = 0
					}
					{
						File = "armor_33.png"
						Size = [1, 1]
						UVRotation = 0
					}
					{
						File = "armor_66.png"
						Size = [1, 1]
						UVRotation = 0
					}
				]
			}
       }
