function Write-Menu {
    <#
    .SYNOPSIS
        Outputs a menu when given an array
    .DESCRIPTION
        Outputs menu and gives options to choose an item when given an array.
        You can choose which property to show in menu.
    .EXAMPLE
        PS C:\> Write-Menu (Get-ChildItem) -DisplayProperty BaseName
        Prints out all Items from Get-ChildItem in a numbered menu with the Items BaseName
    .INPUTS
        -ChoiceItems []
        -DisplayProperty <string>
    .OUTPUTS
        Numbered menu
    .NOTES
        
    #>
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)][array]$Items,
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName)][string]$Name
    )
    
    begin {
        #$currentState = 0
        $searchMenu = [ordered] @{ }
    }
    process { 
        $ChoiceItems += $Items
    }
    end {
        $htMenu = [ordered] @{ }
        for ($i = 1; $i -le $ChoiceItems.Count; $i++) {
            Write-Verbose "Adding $($ChoiceItems[$i - 1]) as choice $i"
            $htMenu.Add("$i", $ChoiceItems[$i - 1])
        }
        #$htMenu.Add("b", "Go back")
        $htMenu.Add("q", "Quit")
            
        if ($htMenu.Count -ge 5) {
            do {
                [string]$answer = (Read-Host "This will print $($htMenu.Count-1) options`nDo you want to (s)earch, (l)ist or (q)uit?").ToLower()
            } while ($answer -notin "s", "l", "q")
            if ($answer -eq "s") {
                $searchString = Read-Host -Prompt "Search for"
                $searchResults = $htMenu.GetEnumerator() | Where-Object { $_.Value.Name -match $searchString }
                for ($i = 1; $i -le $searchResults.Count; $i++) {
                    Write-Verbose "Adding $($searchResults[$i - 1]) as choice $i"
                    $searchMenu.Add("$i", $searchResults[$i - 1].Value)
                }
                $searchMenu.Add("q", "Quit")
                foreach ($key in $searchMenu.Keys) {
                    if ($key -eq "q") {
                        Write-Host "'$key' for: $($searchMenu[$key])"
                    }
                    else {
                        Write-Host "'$key' for: $($searchMenu[$key].$Name)"
                    }
                }
                    
                do {
                    [string]$choice = Read-Host "Choice"
                } until ($choice -in $searchMenu.Keys)
                    
                if ($choice -eq "q") {
                    return
                }
                return $searchMenu[$choice]
            }
            if ($answer -eq "q") {
                return
            }
        }

        foreach ($key in $htMenu.Keys) {
            if ($key -eq "q") {
                Write-Host "'$key' for: $($htMenu[$key])"
            }
            else {
                if ($searchString -and $htMenu[$key].$Name -notlike "*$searchString*") {
                    #Write-Host "'$key' for: $($htMenu[$key].$Name)"
                }
                else {
                    Write-Host "'$key' for: $($htMenu[$key].$Name)"
                }
            }
        }

        do {
            [string]$choice = Read-Host "Choice"
        } until ($choice -in $htMenu.Keys)
            
        if ($choice -eq "q") {
            return
        }
        return $htMenu[$choice]
    }
}