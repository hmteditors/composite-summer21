export JULIA=`which julia`

$JULIA buildscripts/archive.jl && $JULIA buildscripts/normalized.jl
$JULIA buildscripts/verify.jl