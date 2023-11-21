*** runmplus_read_svalues.ado
*** Rich Jones
*** February 4, 2016
***    This ado reads an Mplus output file
*** and looks for the svalues part of the output
*** values are saved to a txt file and to a matrix

* tested in single group models

version 13

capture program drop runmplus_read_svalues
program define runmplus_read_svalues , rclass

syntax , out(string) [debug ]

qui {

if `c(N)'~=0 {
   qui tempfile odata
   qui save `odata' , replace
   qui local recallodata=1
}


if "`debug'"=="debug" {
   noisily di _n _col(3) "... now running runmplus_read_svalues.ado" _n ///
                _col(7) "with debug mode on." _n _n ///
                _col(3) "`out' <- the value for local out" _n _n
}


local lookfor "MODEL COMMAND WITH FINAL ESTIMATES USED AS STARTING VALUES"
local out "`out'"
infix str col1 1 str col2 1-2 str line 1-99 using `out' , clear
format line %99s
gen linenum=_n
gen target=lower(trim(line))==lower(trim("`lookfor'"))
su target
if `r(max)'==0 {
   noisily di in green _n _n _col(5) "NB: " in yellow "SVALUES " in green "not found in Mplus output file, " _n ///
      in green _col(5) "make sure out(svalues;) option in runmplus." _n ///
      in green _col(5) "Now exiting runmplus_read_svalues.ado" in yellow " * * * " _n _n
   exit
}
su linenum if target==1
local start = r(min)
gen break=1 if trim(line)~=""&trim(line[_n-1])==""&trim(line[_n-2])==""
su linenum if linenum>`start' & break==1
local end = r(min)
keep if inrange(linenum,`start',`end')
drop if target==1
drop if col1~=""
drop if trim(line)==""
drop if regexm(line,"Beginning Time:")
keep line
outsheet line using svalues.txt , nonames nocomma noq replace
noisily di in yellow "svalues.txt" in green " saved"
local svalues ""
forvalues i=1/`c(N)' {
   local foo = line[`i']
   local svalues "`svalues' `foo'"
}
list line in 1
list line in `c(N)'
if reverse(word(reverse("`svalues'"),1))~=line[`c(N)'] {
   noisily di in green _n _n _col(5) "NB: " in green "local macro " in yellow "svalues" ///
      in green " fails consistency check, " _n ///
      in green "and will not be saved. Proceed with caution" in yellow " * * * " _n _n
}
if reverse(word(reverse("`svalues'"),1))==line[`c(N)'] {
  noisily di in green "local macro passes consistency check"
}
replace line=lower(trim(line))
cap strparse line , parse(*) gen(p)
if _rc~=0 {
   noisily di in green _n _n _col(5) "NB: " in green "This program requires" ///
      in smcl `"{stata "ssc install strparse": strparse} to run (click link to install)."'
}
gen at=regexm(line,"@")
gen mean=regexm(line,"\[")
gen delta=regexm(line,"\{")
gen thresholds=strpos(line,"$")>0
gen var=mean==0&delta==0&thresholds==0&(regexm(line," on ")==0)&(regexm(line," by ")==0)&(regexm(line," with ")==0)
replace line=subinstr(line,";","",1)
replace line=subinstr(line,"[","",1)
replace line=subinstr(line,"]","",1)
replace line=subinstr(line,"{","",1)
replace line=subinstr(line,"}","",1)
replace line=subinstr(line,"*","@",1)
cap drop p*
strparse line , gen(p) parse("@")
gen rowname="thresholds_"+p1 if thresholds==1
replace rowname="intercepts_"+p1 if thresholds==0 & mean==1
replace rowname="scales_"+p1 if delta==1
replace rowname="variances_"+p1 if var==1
replace rowname=p1 if mean==0 & delta==0 & thresholds==0 & var==0
replace rowname=subinstr(rowname," ","_",.)
keep rowname p2 at
order rowname p2 at
rename p2 estimate
destring estimate, replace force
mkmat estimate at , matrix(sv) rownames(rowname)
noisily di in green "matrix " in yellow "svalues" in green " in return results" _n

if "`recallodata'"=="1" {
   use `odata' , clear
}

return local svalues "`svalues'"
return matrix Svalues = sv

} // close qui


end



* have a nice day

