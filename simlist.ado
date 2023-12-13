program define simlist , rclass
syntax , *
local elements = wordcount("`options'")
local i=1
foreach x in `options' {
	local e`i'  "`x'=r(`x') "
	local w "`w' `e`i''"
	local i=`i'+1
}
return local elements=`elements'
return local simlist "`w'"
di in green "   simlist:   " in yellow "`w'"
end

