# odklabel - ODK XLSForm Labeling for Stata

## About ODK

This package works with data collected using Open Data Kit (ODK), an open-source suite of tools for mobile data collection. ODK is maintained by Get ODK Inc. and the ODK community. Learn more at https://getodk.org

**odklabel is an independent, community-created tool and is not officially affiliated with or endorsed by Get ODK Inc.**

## Description

`odklabel` is a lightweight Stata package that automatically generates variable and value labels for datasets collected using ODK by reading the XLSForm Excel file. It focuses solely on labeling already-imported data, making it fast and flexible for modern ODK workflows.

## Features

- Automatic variable and value labels from XLSForm (survey and choices sheets)
- Support for select_one and select_multiple questions
- Optional group prefix removal and note variable removal
- Variable name case control (preserve/lower/upper)
- Immediate execution option for one-step workflows

## Installation

### Method 1: Manual Installation

1. Download all files: `odklabel.ado`, `odklabel.sthlp`, and `odklabel.pkg`
2. Find your Stata personal ado directory by typing in Stata:
   ```stata
   sysdir
   ```
3. Copy the files to the PLUS directory shown
4. Alternatively, place them in your current working directory

### Method 2: From GitHub 

```stata
net install odklabel, from("https://raw.githubusercontent.com/samwel2000/odklabel/master/")
```
## Syntax

```stata
odklabel using filename, formname(string) [labelcolumn(string) savepath(string) 
    case(preserve|lower|upper) groupremove noteremove capture do]
```

**Required:** `formname(string)` - Name of the ODK form (used in output filename)

**Optional:**
- `labelcolumn(string)` - Label column name in XLSForm (default: "label")
- `savepath(string)` - Directory to save output do-file (default: current directory)
- `case(preserve|lower|upper)` - Variable name case transformation (default: preserve)
- `groupremove` - Include code to remove group prefixes
- `noteremove` - Include code to drop note variables
- `capture` - Add capture prefix to all commands
- `do` - Execute the generated labeling script immediately

## Quick Start

### Method 1: Two-Step Process

```stata
* Generate labeling do-file from XLSForm
odklabel using "baseline_survey.xlsx", formname(baseline)

* Load your ODK dataset
use "baseline_data.dta", clear

* Apply the labels
do "Labelling_baseline.do"
```

### Method 2: One-Step Process

```stata
* Load your ODK dataset first
use "baseline_data.dta", clear

* Generate and immediately apply labels
odklabel using "baseline_survey.xlsx", formname(baseline) case(lower) capture do
```

## Examples

### Example 1: Basic labeling
```stata
odklabel using "survey.xlsx", formname(baseline)
```

### Example 2: Multiple language support
```stata
* If your XLSForm has label::English, use labelenglish (remove :: and special chars)
odklabel using "survey.xlsx", formname(baseline) labelcolumn(labelenglish)
```

### Example 3: Lowercase variable names with group removal
```stata
odklabel using "survey.xlsx", formname(baseline) case(lower) groupremove
```

### Example 4: Generate and apply labels immediately
```stata
* Load your data first
import delimited "baseline_data.csv", clear

* Generate and apply in one command
odklabel using "baseline_form.xlsx", formname(baseline) case(lower) capture do
```

### Example 5: Complete workflow (two-step)
```stata
* Step 1: Import ODK data
import delimited "baseline_data.csv", clear

* Step 2: Generate labeling script
odklabel using "baseline_form.xlsx", formname(baseline) ///
    case(lower) groupremove noteremove capture

* Step 3: Apply labels
do "Labelling_baseline.do"

* Step 4: Save labeled dataset
save "baseline_labeled.dta", replace
```

### Example 6: Complete workflow (one-step with do option)
```stata
* Step 1: Import ODK data
import delimited "baseline_data.csv", clear

* Step 2: Generate and apply labels in one command
odklabel using "baseline_form.xlsx", formname(baseline) ///
    case(lower) groupremove noteremove capture do

* Step 3: Save labeled dataset
save "baseline_labeled.dta", replace
```

### Example 7: All options
```stata
odklabel using "endline_survey.xlsx", formname(endline) ///
    labelcolumn(label::English) ///
    savepath("C:/Projects/DoFiles") ///
    case(lower) ///
    groupremove noteremove capture
```

## Requirements

- Stata 13.0 or higher
- XLSForm with 'survey' and 'choices' sheets in standard ODK format
- `sxpose` package (auto-installed when using `groupremove` option)

## How It Works

Reads your XLSForm and generates label commands. Two workflows available:
- **Two-step:** Generate do-file → Run manually
- **One-step:** Use `do` option to apply immediately

## Tips

- Use `capture` when your dataset might not have all form variables
- Use `case(lower)` if ODK exports lowercase but your form has mixed case  
- Use `groupremove` for cleaner variable names from nested groups
- Combine `capture do` for robust one-step labeling
- Test on small data first

## Troubleshooting

- **File not found:** Check XLSForm path
- **Sheet not found:** Ensure 'survey' and 'choices' sheets exist
- **Labels not applying:** Check variable name case matches
- **Some labels missing:** Use `capture` option

## Version History

- **v1.0.0** (January 2026) - Initial release

## Credits

Initial code by Charles Festo. Modified and packaged by Samwel Lwambura with additions for multiple select labeling, flexible options, and installable package format.

## Author

Samwel Lwakatare  
Ifakara Health Institute 
samwelgfrey@gmail.com

## Support

GitHub Issues: https://github.com/samwel2000/odklabel/issues

## License

MIT License

## Acknowledgments

This package streamlines ODK-to-Stata workflows. Special thanks to the ODK community and Get ODK Inc. for maintaining the open-source ODK platform.
