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
        [parameter(ValueFromPipeline)][array]$Item,
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias("Name")]
        [string]$DisplayName
    )
    
    begin {
        $htMenu = [ordered] @{ }
        $htDisplayName = [ordered] @{ }
        $counter = 1
        function Add-MenuOptions {
            param (
                $Menu
            )
            try {
                $Menu.Add("b", "Go back")
                $Menu.Add("q", "Quit")
            }
            catch {}
            return $Menu
        }
        function Get-Menu {
            [CmdletBinding()]
            param (
                $Menu = @{},
                $DisplayName,
                $SearchString
            )
            if ($null -eq $SearchString) {
                $Menu = Add-MenuOptions $Menu
                foreach ($key in $Menu.Keys) {
                    switch ($key) {
                        ({ $_ -in "q", "b" }) { Write-Host "'$key' for: $($Menu[$key])"; break }
                        Default { Write-Host "'$key' for: $($DisplayName[$key])" }
                    }
                }
                do {
                    [string]$choice = Read-Host "Choice"
                } until ($choice -in $Menu.Keys)
                if ($choice -in "q", "b") {
                    return $choice
                }
                return $Menu[$choice]
            }
            else {
                $searchMenu = [ordered] @{ }
                $searchDisplayName = [ordered] @{ }
                $searchResults = $menu.GetEnumerator() | Where-Object { $_.Value.Name -match $searchString }
                $indexCounter = 1
                foreach ($result in $searchResults) {
                    Write-Verbose "Adding $($result.Value) as choice $indexCounter"
                    $searchMenu.Add("$indexCounter", $result.Value)
                    $searchDisplayName.Add("$indexCounter", $DisplayName[$result.Key])
                }
                $searchMenu = Add-MenuOptions $searchMenu
                foreach ($key in $searchMenu.Keys) {
                    switch ($key) {
                        ({ $_ -in "q", "b" }) { Write-Host "'$key' for: $($searchMenu[$key])"; break }
                        Default { Write-Host "'$key' for: $($searchDisplayName[$key])" }
                    }
                }
                do {
                    $choice = Read-Host "Choice"
                } until ($choice -in $searchMenu.Keys)
                if ($choice -notmatch '^[0-9]+$') {
                    return $choice
                }
                return $searchMenu[$choice]
            }
        }
    }
    process {
        $Item.ForEach(
            {
                Write-Verbose "Adding $_ as choice $counter"
                $htMenu.Add("$counter", $_)
            }
        )
        $DisplayName.ForEach(
            {
                Write-Verbose "Adding $_ as display name $counter"
                $htDisplayName.Add("$counter", $_)
            }
        )
        $counter++
    }
    end {
        if ($htMenu.Count -ge 1) {
            do {
                [string]$answer = (Read-Host "This will print $(($hashtable.Keys | Where-Object {$_ -notin "b", "q"}).Count) options`nDo you want to (S)earch, (L)ist or (Q)uit?").ToLower()
                switch ($answer) {
                    "s" {
                        $searchString = Read-Host -Prompt "Search for"
                        $res = Get-Menu -Menu $htMenu -DisplayName $htDisplayName -SearchString $searchString
                        if ($res -in "q", "b") { 
                            $answer = $res
                            break
                        }
                        return $res
                    }
                    "l" {
                        $res = Get-Menu -Menu $htMenu -DisplayName $htDisplayName
                        if ($res -in "q", "b") { 
                            $answer = $res
                            break
                        }
                        return $res
                    }
                    "b" {
                        $answer = $null
                    }
                    "q" {
                        return
                    }
                }
            } until ($answer -eq "q") 
        }
        else {
            Get-Menu -Menu $htMenu -Name $htDisplayName
        }
    }
}
