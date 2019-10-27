Function New-PsWebPRoject {
    [CmdletBinding()]
    Param(
        [System.IO.DirectoryInfo]$Path = (Get-item $PSScriptRoot),
        $Name
    )
    #Creates the folder strucuture that is needed for the creation of a webserver
    
    $MainPath = (Join-Path $Path -ChildPath $Name)
    $Paths = [Ordered]@{}
    $Paths.Static = (Join-Path $MainPath -ChildPath 'Static')
    $Paths.Routes = (Join-Path $MainPath -ChildPath 'Routes')
    $Paths.Views = (Join-Path $MainPath -ChildPath 'Views')
    
    $Folders = @(
        (Join-Path $MainPath -ChildPath 'Routes'),
        (Join-Path $MainPath -ChildPath 'Assets\')
    )
        

    Foreach ($Folder in $Paths){
        $null = New-Item -Path $Folder -ItemType Directory -Force
    }
        

    
}

Function New-PSWebRouteFile {
    [String]$Name
}

#New-PsWebPRoject -Path .\devtest -Name "eee"

Function Get-URLData {
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Url,
    
        [Switch]
        $IsValidURL
    )
    $Regex = "(?'FullUrl'(?'Protocol'https?):\/\/(?'DomainName'(www\.)?(?'BaseUrl'[-a-zA-Z0-9@:%_\+~#=]{2,256})(?'Extension'\.[a-z]{2,6}\b)?)(?'Route'[-a-zA-Z0-9@:%_\+.~#?&\/\/=,]+)?)"
    $Url -match $Regex
    
    If($Matches){
        $Hash = @{}
        $Hash.FullUrl = $Matches.FullUrl
        $Hash.DomainName = $Matches.DomainName
        $Hash.Extension = $Matches.Extension
        $Hash.Baseurl = $Matches.BaseUrl
        $Hash.Route = $Matches.Route
        $Hash.Protocol = $Matches.Protocol
    
        Return New-Object psobject -ArgumentList $Hash
        
    }
    
    
    
    
    } 