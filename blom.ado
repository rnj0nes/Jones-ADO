version 10
capture program drop blom
program define blom

* generate new x that is x_blom, a blom-transformed version of x
syntax varlist(min=1 max=1 numeric) [if][in]  , [replace logit nce]

* sample size
marksample touse
qui su `1' if `touse'
local N=`r(N)'

* rank
tempvar rank prank
egen `rank' = rank(`1') if `touse'
gen `prank' = (`rank'-(3/8))/`N'

* blom
cap drop `1'_blom
gen `1'_blom  = invnorm((`rank' - 3/8)/(`N'+.25))

* nce
if "`nce'"=="nce" {
   cap drop `1'_nce
   * http://www.ats.ucla.edu/stat/stata/faq/prank.htm
   * and an insurance policy to prevent out-of-range values inferred from
   * http://en.wikipedia.org/wiki/Normal_curve_equivalent
   foreach x in min max {
      local f=1
      local sign "<"
      if "`x'"=="min" {
         local f=-1
         local sign ">"
      }
      qui su `1'_blom
      local `x'=`f'*`r(`x')'
      qui su `1'_blom if `1'_blom `sign' `r(`x')'
      local jitter=``x''-(`f'*`r(`x')')
      local `x'=``x''+0.5*`jitter'
   }
   local max=max(`max',`min')
   if `max' < 2.3263 {
      gen `1'_nce = invnorm(`prank')*21.06 + 50   
   }
   if `max' >= 2.3263 {
      gen `1'_nce = invnorm(`prank')* ((100*(normal(`max')-.5))/(`max')) + 50
   }
}

* logit
if "`logit'"=="logit" {
   *gen `1'_logit = 1.7*`1'_blom
   gen `1'_logit = ln(`prank'/(1-`prank'))
}

* replace
if "`replace'"=="replace" {
   di in yellow "CAUTION: " in green "replace is a dangerous option."
   di "It replaces `1' with the `nce' `logit' transformed value of `1'."
   if "`nce'"~="nce" & "`logit'"~="logit" {
      drop `1'
      rename `1'_`blom' `1'
   }
   if "`nce'"=="nce" {
      drop `1'
      rename `1'_nce `1'
   }
   if "`logit'"=="logit" {
      drop `1'
      rename `1'_logit `1'
   }
}

end


