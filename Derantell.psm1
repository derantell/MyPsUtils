# Installation 
#   1. Place this file in the '%userprofile%\my documents\WindowsPowerShell\Modules\Derantell\ directory. See $Env:PSModulePath
#   2. Start a Powershell
#   3. run 'Import-Module Derantell'
#   4. run 'Get-Help Remove-Regions' to see some documentation

<#
.SYNOPSIS
Removes regions and empty documentation comment tags from .cs files.
.PARAMETER Filename
The files(s) to deregionalize.
.PARAMETER Encoding
The character encoding of the source files. 
UTF8 is the default. See Out-File for a list of valid encoding values.
.DESCRIPTION 
The Remove-Regions advanced function removes regions and empty documentation comment tags from all files in the input. 
.EXAMPLE
dir c:\myproject -Include *.cs -Recurse | Remove-Regions
This example gets all .cs files recursivly under the c:\myproject directory and pipes them into the Remove-Regions function.
.EXAMPLE
Remove-Regions .\FilthyFile.cs 
This example shows how to call the Remove-Regions passing a file as an argument.
.LINK 
Out-File
#>
Function Remove-Regions {
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact="Low")]
    Param(
        [Parameter( Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelinebyPropertyName=$True)]
        [string[]] 
        $Filename,

        [string] 
        $Encoding = "UTF8"
    )        
    
    BEGIN {
        $regex = [regex]"\s*(?:#(?:end)?region|///\s*<([^/\s>]+).*?>[\s/]*?</\1>).*"
    }
    
    PROCESS {    
        Foreach ($file in $filename) {
            $filepath = resolve-path $file
            try {
                if ($PSCmdlet.ShouldProcess($file, "Remove regions")) {
                    $regex.Replace([System.IO.File]::ReadAllText($filepath),
                        {param($m) if($m.Value.Contains('endregion')){"`n`n"} else {''}}) `
                        | out-file $file -force -encoding $Encoding
                }
            } catch {
                write-warning "Failed to sanitize $filepath: $_"
            } finally {
                write-output $file
            } 
        }
    }
}
