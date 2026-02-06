*! odklabel v1.0.0
*! Creates variable and value labels from ODK XLSForm
*! Author: Samwel Lwambura (samwelgfrey@gmail.com)
*! Date: January 2026

program define odklabel
    version 13.0
    syntax using/, FORMname(string) [LABELColumn(string) SAVEPath(string) CASE(string) GROUPremove NOTEremove CAPture DO]
    
    * Set defaults
    if "`labelcolumn'" == "" {
        local labelcolumn "label"
    }
    
    if "`savepath'" == "" {
        local savepath "."
    }
    
    if "`case'" == "" {
        local case "preserve"
    }
    
    * Validate case option
    if !inlist("`case'", "preserve", "lower", "upper") {
        di as error "case() must be one of: preserve, lower, upper"
        exit 198
    }
    
    * Set capture prefix
    local cap_prefix = ""
    if "`capture'" != "" {
        local cap_prefix = "cap "
    }
    
    * Store original data
    tempfile original
    quietly save `original', emptyok
    
    * Validate that the Excel file exists
    capture confirm file "`using'"
    if _rc {
        di as error "File `using' not found"
        exit 601
    }
    
    * Check if required sheets exist
    quietly {
        capture import excel "`using'", sheet("survey") clear
        if _rc {
            noisily di as error "Sheet 'survey' not found in `using'"
            exit 603
        }
        
        capture import excel "`using'", sheet("choices") clear
        if _rc {
            noisily di as error "Sheet 'choices' not found in `using'"
            exit 603
        }
    }
    
    di as text "Creating labeling do-file for form: `formname'"
    di as text "Using label column: `labelcolumn'"
    di as text "Variable name case: `case'"
    if "`groupremove'" != "" {
        di as text "Remove group prefixes: Yes"
    }
    if "`noteremove'" != "" {
        di as text "Remove note variables: Yes"
    }
    if "`capture'" != "" {
        di as text "Use capture prefix: Yes"
    }
	if "`do'" != "" {
        di as text "Execute labeling script: Yes"
    }
    di as text ""
	di as text "________________________________________________________________"
	di as text ""
    
	*==========================================================================
    * PART 1: REMOVING GROUPS IN VARIABLE NAMES
    *==========================================================================
    if "`groupremove'" != "" {
        quietly {
            import excel "`using'", sheet("survey") case(lower) firstrow clear 
            keep if index(type,"begin")
            keep name 
            
            * Apply case transformation to variable names
            if "`case'" == "lower" {
                replace name = lower(name)
            }
            else if "`case'" == "upper" {
                replace name = upper(name)
            }
            
            count 
            local novariables `r(N)'
            
            if `novariables' > 0 {
                capture which sxpose
                if _rc {
                    noisily di as text "Installing sxpose..."
                    ssc install sxpose
                }
                
                sxpose, clear 
                egen allvar = concat(_var1-_var`novariables'), punct(" ")
                keep allvar
                gen foreachcode = "foreach varname in " + allvar + " {" 
                gen label_command_1 = "`cap_prefix'" + "renpfix " + "`" + "varname" + "'"
                gen label_command_2 = "}"
                
                keep foreachcode label_command*
                reshape long label_command_, i(foreachcode) j(_j)
                
                file open handle using "`savepath'/Labelling_`formname'.do", write text append
                file write handle "" _n
                file write handle "*****************************Removing group names*************************" _n
                file write handle (foreachcode) _n
                forvalues i = 1/`=_N' {
                    file write handle (label_command[`i']) _n
                } 
                file close handle
            }
        }
        di as text "✓ Group name removal code created"
    }
	
	
    *==========================================================================
    * PART 2: LABELLING VARIABLES
    *==========================================================================
    quietly {
        import excel "`using'", sheet("survey") case(lower) firstrow clear 
        keep type name `labelcolumn'
        rename `labelcolumn' label
        
        drop if name=="" | type=="note" | type=="begin group" | type=="end group" ///
            | type=="begin repeat" | type=="calculate" | type=="name" | type=="start" ///
            | type=="end" | type=="deviceid" | type=="gps" | type=="begin_group" ///
            | type=="begin_repeat" | type=="end_group" | type=="end_repeat"
        compress
        drop if label==""
        
        * Apply case transformation to variable names
        if "`case'" == "lower" {
            replace name = lower(name)
        }
        else if "`case'" == "upper" {
            replace name = upper(name)
        }
        * if preserve, keep as is
        
        * Statement for labelling variables
        gen varlabel_command_1 = "`cap_prefix'" + "lab var " + name + `" ""' + label + `"""' 
        
        * Write to do file
        file open handle using "`savepath'/Labelling_`formname'.do", write text replace
        file write handle "" _n
        file write handle "*****************************Labelling variables*************************" _n
        forvalues i = 1/`=_N' {
            file write handle (varlabel_command_[`i']) _n
        }
        file close handle
    }
    di as text "✓ Variable labels created"
    
    *==========================================================================
    * PART 3: LABELING VALUES OF VARIABLES (select_one)
    *==========================================================================
    quietly {
        import excel "`using'", sheet("survey") case(lower) firstrow clear 
        keep if index(type,"select_one")
        split type
        keep type2 name
        rename type2 label_name
        replace label_name = trim(label_name)
        
        * Apply case transformation to variable names
        if "`case'" == "lower" {
            replace name = lower(name)
        }
        else if "`case'" == "upper" {
            replace name = upper(name)
        }
        
        rename name varname
        tempfile choices
        save `choices'
        
        * Reading choices
        import excel "`using'", sheet("choices") case(lower) firstrow clear 
        destring name, replace force
        drop if missing(name)
        
        rename list_name label_name
        rename name value
        rename `labelcolumn' value_label
        keep value_label value label_name
        
        tostring value, replace
        by label_name (value), sort: gen label_command_1 = "`cap_prefix'" + "lab define " + label_name ///
            + " " + (value) + `" ""' + value_label + `"""' if _n == 1
        by label_name (value): replace label_command_1 = label_command_1[_n-1] ///
            + " " + (value) + `" ""' + value_label + `"""' if _n > 1
        by label_name (value): keep if _n == _N
        keep label_name label_command_1
        
        * Get variable names
        merge 1:m label_name using `choices'
        keep if _merge == 3
        
        * Create the statement to lab val
        gen label_command_2 = "`cap_prefix'" + "lab values " + varname + " " + label_name
        
        * Reshape to create the commands
        keep label_name varname label_command*
        duplicates drop varname, force
        reshape long label_command_, i(varname) j(_j)
        
        file open handle using "`savepath'/Labelling_`formname'.do", write text append
        file write handle "" _n
        file write handle "*****************************Labelling values*************************" _n
        forvalues i = 1/`=_N' {
            file write handle (label_command[`i']) _n
        } 
        file close handle
    }
    di as text "✓ Value labels created (select_one)"
	
    
    *==========================================================================
    * PART 4: REMOVING NOTE TYPE VARIABLES FROM THE DATASET
    *==========================================================================
    if "`noteremove'" != "" {
        quietly {
            import excel "`using'", sheet("survey") case(lower) firstrow clear  
            keep if index(type,"note")
            keep name 
            
            * Apply case transformation to variable names
            if "`case'" == "lower" {
                replace name = lower(name)
            }
            else if "`case'" == "upper" {
                replace name = upper(name)
            }
            
            count
            if `r(N)' > 0 {
                gen varlabel_command_1 = "`cap_prefix'" + "drop " + name  
                
                file open handle using "`savepath'/Labelling_`formname'.do", write text append
                file write handle "" _n
                file write handle "*****************************Removing notes*************************" _n
                forvalues i = 1/`=_N' {
                    file write handle (varlabel_command_[`i']) _n
                }
                file close handle
            }
        }
        di as text "✓ Note variable removal code created"
    }
    
    *==========================================================================
    * PART 5: LABEL MULTIPLE SELECT CHOICES VARIABLES
    *==========================================================================
    quietly {
        import excel "`using'", sheet("survey") case(lower) firstrow clear 
        keep if index(type,"select_multiple")
        
        count
        if `r(N)' > 0 {
            split type
            keep type2 name `labelcolumn'
            rename type2 label_name
            replace label_name = trim(label_name)
            
            * Apply case transformation to variable names
            if "`case'" == "lower" {
                replace name = lower(name)
            }
            else if "`case'" == "upper" {
                replace name = upper(name)
            }
            
            rename name varname
            rename `labelcolumn' varlabel
            tempfile choices
            save `choices'
            
            import excel "`using'", sheet("choices") case(lower) firstrow clear 
            destring name, replace force
            drop if missing(name)
            
            rename list_name label_name
            rename name value
            rename `labelcolumn' value_label
            keep value_label value label_name
            di as text "I reached here"
            * Get variable names
            merge m:m label_name using `choices'
            keep if _merge == 3
            
            * Statement to label variables
            gen variable = varname + string(value)
			replace variable = subinstr(variable, " ", "", .)
			if "`case'" == "lower" {
                replace variable = lower(variable)
            }
            else if "`case'" == "upper" {
                replace variable = upper(variable)
            }
			
            gen label_command_2 = "`cap_prefix'" + "lab var " + variable + " " + `"""' ///
                + varlabel + ": " + value_label + `"""'
            
            * Label and their values
            set obs `=_N + 1'
            replace label_command_2 = "`cap_prefix'" + "lab def smultid 0 No 1 Yes" in L
            set obs `=_N + 1'
            levelsof variable, clean sep("  ")
            replace label_command_2 = "`cap_prefix'" + "lab values " + "`r(levels)'" + " smultid" in L
            
            file open handle using "`savepath'/Labelling_`formname'.do", write text append
            file write handle "" _n
            file write handle "******************Labelling variable for multiple select items***********" _n
            forvalues i = 1/`=_N' {
                file write handle (label_command[`i']) _n
            } 
            file close handle
        }
    }
    di as text "✓ Multiple select labels created"
    
    * Restore original data
    quietly use `original', clear
    
    di as text ""
    di as result "Do-file successfully created: `savepath'/Labelling_`formname'.do"
	
	* If DO option specified, run the labeling script
    if "`do'" != "" {
        di as text ""
        di as text "{hline 60}"
        di as result "Executing labeling script..."
        di as text "{hline 60}"
        
        * Restore original dataset
        quietly use `original', clear
        
        * Run the labeling do-file
        capture noisily do "`savepath'/Labelling_`formname'.do"
        
        if _rc == 0 {
            di as text "{hline 60}"
            di as result "✓ Labels successfully applied to current dataset"
            di as text "{hline 60}"
        }
        else {
            di as error "{hline 60}"
            di as error "Error: Labeling script failed with return code " _rc
            di as error "Review the output above for details"
            di as error "{hline 60}"
            exit _rc
        }
    } 
	else {
		di as text "Run this file to apply labels to your ODK dataset"
	}
    
    
end
