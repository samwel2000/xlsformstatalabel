{smcl}
{* *! version 1.0.0  31jan2026}{...}
{viewerjumpto "Syntax" "odklabel##syntax"}{...}
{viewerjumpto "Description" "odklabel##description"}{...}
{viewerjumpto "Options" "odklabel##options"}{...}
{viewerjumpto "Examples" "odklabel##examples"}{...}
{viewerjumpto "Author" "odklabel##author"}{...}
{title:Title}

{phang}
{bf:odklabel} {hline 2} Create variable and value labels from ODK XLSForm


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:odklabel}
{cmd:using} {it:filename}{cmd:,}
{cmdab:form:name(}{it:string}{cmd:)}
[{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{cmdab:form:name(}{it:string}{cmd:)}}name of the ODK form (used in output filename){p_end}

{syntab:Optional}
{synopt:{cmdab:labelc:olumn(}{it:string}{cmd:)}}name of the label column in XLSForm; default is {cmd:label}{p_end}
{synopt:{cmdab:savep:ath(}{it:string}{cmd:)}}directory path to save the output do-file; default is current directory{p_end}
{synopt:{cmdab:case(}{it:preserve}|{it:lower}|{it:upper}{cmd:)}}case transformation for variable names; default is {cmd:preserve}{p_end}
{synopt:{opt groupremove}}include code to remove group prefixes from variable names{p_end}
{synopt:{opt noteremove}}include code to drop note-type variables from dataset{p_end}
{synopt:{opt capture}}add {cmd:cap} prefix to all generated commands for error suppression{p_end}
{synopt:{opt do}}execute the generated labeling script immediately on the current dataset{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:odklabel} reads an ODK (Open Data Kit) XLSForm Excel file and generates a Stata do-file 
containing commands to label variables and values in datasets collected using that form. This 
automates the labeling process and ensures consistency between the ODK form design and the 
Stata dataset.

{pstd}
The command creates a do-file named {it:Labelling_formname.do} that contains:

{phang2}• Variable labels from the survey sheet{p_end}
{phang2}• Value labels for select_one questions{p_end}
{phang2}• Value labels for select_multiple questions{p_end}
{phang2}• Optionally, code to remove group prefixes from variable names{p_end}
{phang2}• Optionally, code to drop note-type variables{p_end}

{pstd}
The XLSForm Excel file must contain at minimum two sheets: {bf:survey} and {bf:choices}, 
following the standard ODK XLSForm structure.


{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{cmd:formname(}{it:string}{cmd:)} specifies the name of the ODK form. This is used to name 
the output do-file (e.g., {it:Labelling_baseline.do}). This option is required.

{dlgtab:Optional}

{phang}
{cmd:labelcolumn(}{it:string}{cmd:)} specifies which column in the XLSForm contains the 
labels to use. The default is {cmd:label}. If your form has multiple language labels 
(e.g., {cmd:label::English}, {cmd:label::French}), specify the appropriate column name.

{phang}
{cmd:savepath(}{it:string}{cmd:)} specifies the directory where the output do-file should 
be saved. The default is the current working directory ({cmd:.}). Use absolute or relative 
paths (e.g., {cmd:"C:/Projects/DoFiles"} or {cmd:"./output"}).

{phang}
{cmd:case(}{it:preserve}|{it:lower}|{it:upper}{cmd:)} controls case transformation of 
variable names in the generated labeling commands:

{phang2}{cmd:preserve} - keeps variable names as they appear in the XLSForm (default){p_end}
{phang2}{cmd:lower} - converts all variable names to lowercase{p_end}
{phang2}{cmd:upper} - converts all variable names to UPPERCASE{p_end}

{pmore}
This is useful when your ODK dataset imports with different case than specified in the form.

{phang}
{cmd:groupremove} includes code in the output do-file to remove group prefixes from variable 
names. ODK often prefixes variable names with their group names (e.g., {cmd:demographics_age}). 
This option generates code using {cmd:renpfix} to remove these prefixes.

{phang}
{cmd:noteremove} includes code in the output do-file to drop note-type variables. Notes in 
ODK forms are informational text shown to enumerators and are not actual data variables. This 
option generates {cmd:drop} commands to remove them from your dataset.

{phang}
{cmd:capture} prefixes all generated labeling commands with {cmd:cap} (capture). This suppresses 
errors if a variable doesn't exist in the dataset, allowing the labeling script to continue 
running. Useful when the dataset might not contain all variables defined in the form.

{phang}
{cmd:do} executes the generated labeling script immediately on the current dataset in memory. 
When this option is specified, {cmd:odklabel} will automatically run the created do-file and 
apply all labels to your data. If not specified, the do-file is created but you must run it 
manually. This option is convenient for streamlined workflows where you want to generate and 
apply labels in one step.


{marker examples}{...}
{title:Examples}

{phang}{bf:Basic usage:}{p_end}
{phang2}{cmd:. odklabel using "baseline_survey.xlsx", formname(baseline)}{p_end}

{phang}{bf:Specify a different label column:}{p_end}
{phang2}{cmd:. odklabel using "survey.xlsx", formname(endline) labelcolumn(label::English)}{p_end}

{phang}{bf:Save output to a specific directory:}{p_end}
{phang2}{cmd:. odklabel using "form.xlsx", formname(midline) savepath("C:/DoFiles")}{p_end}

{phang}{bf:Convert variable names to lowercase:}{p_end}
{phang2}{cmd:. odklabel using "form.xlsx", formname(baseline) case(lower)}{p_end}

{phang}{bf:Include group removal and note removal:}{p_end}
{phang2}{cmd:. odklabel using "form.xlsx", formname(baseline) groupremove noteremove}{p_end}

{phang}{bf:Add capture prefix to all commands:}{p_end}
{phang2}{cmd:. odklabel using "form.xlsx", formname(baseline) capture}{p_end}

{phang}{bf:Generate and immediately apply labels:}{p_end}
{phang2}{cmd:. odklabel using "form.xlsx", formname(baseline) do}{p_end}

{phang}{bf:One-step workflow - load data and apply labels:}{p_end}
{phang2}{cmd:. use "baseline_data.dta", clear}{p_end}
{phang2}{cmd:. odklabel using "baseline_form.xlsx", formname(baseline) case(lower) capture do}{p_end}

{phang}{bf:Complete example with all options:}{p_end}
{phang2}{cmd:. odklabel using "baseline_survey.xlsx", formname(baseline) ///}{p_end}
{phang3}{cmd:labelcolumn(label::English) savepath("./dofiles") ///}{p_end}
{phang3}{cmd:case(lower) groupremove noteremove capture}{p_end}


{title:Workflow}

{pstd}
Typical workflow for using {cmd:odklabel}:

{pstd}
{bf:Method 1: Two-step process}

{phang2}1. Export your ODK data to Stata (.dta) or CSV format{p_end}
{phang2}2. Run {cmd:odklabel} on your XLSForm to create the labeling do-file{p_end}
{phang2}3. Load your ODK dataset in Stata{p_end}
{phang2}4. Run the generated labeling do-file to apply all labels{p_end}

{pstd}
Example:

{phang2}{cmd:. import delimited "baseline_data.csv", clear}{p_end}
{phang2}{cmd:. odklabel using "baseline_form.xlsx", formname(baseline) case(lower) capture}{p_end}
{phang2}{cmd:. do "Labelling_baseline.do"}{p_end}

{pstd}
{bf:Method 2: One-step process (using {cmd:do} option)}

{phang2}1. Load your ODK dataset in Stata{p_end}
{phang2}2. Run {cmd:odklabel} with the {cmd:do} option to generate and apply labels immediately{p_end}

{pstd}
Example:

{phang2}{cmd:. use "baseline_data.dta", clear}{p_end}
{phang2}{cmd:. odklabel using "baseline_form.xlsx", formname(baseline) case(lower) capture do}{p_end}


{title:Requirements}

{pstd}
• Stata version 13.0 or higher{p_end}
{pstd}
• {cmd:sxpose} package (auto-installed if {cmd:groupremove} is specified){p_end}
{pstd}
• XLSForm must have {bf:survey} and {bf:choices} sheets{p_end}


{title:Stored results}

{pstd}
{cmd:odklabel} does not store any results in {cmd:r()} or {cmd:e()}. It creates a do-file 
on disk that can be executed separately.


{marker author}{...}
{title:Author}

{pstd}
Samwel Lwambura{break}
Ifakara Health Institute{break}
samwelgfrey@gmail.com{break}


{title:Also see}

{psee}
Online: {helpb import excel}, {helpb label}, {helpb rename}
{p_end}
