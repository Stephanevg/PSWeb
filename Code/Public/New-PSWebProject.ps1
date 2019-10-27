Function New-PsWebPRoject {
    #Main entry point to create the pswebproject
    #This is to create a project folder template.
    #This will not run your server. For that, use Start-PSWebServer
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
    
    $conf = [PsWebConfig]::New($Paths.Static,$Paths.Routes,$Paths.Views)

    $Folders = @(
        (Join-Path $MainPath -ChildPath 'Static'),
        (Join-Path $MainPath -ChildPath 'Routes'),
        (Join-Path $MainPath -ChildPath 'Static\Styles')
        (Join-Path $MainPath -ChildPath 'Assets\')
    )
        

    Foreach ($Key in $Paths.Keys){
        $null = New-Item -Path $Paths.$key -ItemType Directory -Force
    }
        
    
    New-Variable -name PSWebConfig -Value $Conf -Force -Scope global

    $Conf | ConvertTo-Json | out-file (Join-Path $MainPath -ChildPath Config.json) -Force
    
}

#Should be singleton
Class PsWebConfig {
    [String[]]$Static
    [String[]]$Views
    [String[]]$Routes
    $Models

    hidden PsWebConfig([String[]]$Static,[String[]]$Views,[String[]]$Routes){
        $this.Static = $Static
        $this.Views = $Views
        $this.Routes = $Routes
    }

    PsWebConfig([System.Io.FileInfo]$Path){
        If($Path.Exists){
            $Config = (get-Content -Path $Path.FullName) | ConvertFrom-Json

            $this.Static = $Config.Static
            $this.Views = $Config.Views
            $this.Routes = $Config.Routes
        }
    }

    [String[]] GetStatic(){
        return $this.Static
    }

    [String[]] GetViews(){
        Return $this.Views
    }

    
    [String[]] GetRoutes(){
        Return $this.Routes
    }

    [String[]] GetModels(){
        Return $this.Models
    }
}

Enum RouteType {
    GET
    POST
    PUT

}

Enum BackEndType {
    Polaris
    Pode
}
Function Start-PswebServer {
        <#
            Start the webserver.
            Load the config file
        #>
        [CmdletBinding()]
    Param(
        $Port = 8080
    )

    If(!($PSWebConfig)){
        #Get the config singleton
        Initialize-PSWebConfig
    }

    

    #Dot source routes

    $Routes = $PSWebConfig.GetRoutes()

    Foreach($Route in $PSWebConfig.GetRoutes()){
        & $Route
    }
    #Start Polaris Webserver

    Start-Polaris -port $port
}

Class PsWebRoute {
    
    [String]$Name
    [String]$RoutePath
    [RouteType]$RouteType = [RouteType]::GET
    [ScriptBlock]$ScriptBlock
    [String] $BackEndType
    [Bool]$Force = $false
    hidden [System.IO.DirectoryInfo]$FolderPath
    [System.IO.FileInfo]$Path

    PsWebRoute(){}

    PsWebRoute([String]$RoutePath,[RouteType]$RouteType){

    }

    [String] GetBackEndType(){
        return $This.BackEndType
    }

    SetBackEndType([BackEndType]$BackEndType){
        $this.BackEndType = $BackEndType
    }

    SetRouteType([RouteType]$RouteType){
        $this.RouteType = $RouteType
    }

    SetfolderPath([system.Io.DirectoryInfo]$Folder){
        $This.FolderPath = $Folder
        $This.SetPath()
    }

    Hidden [void]SetPath(){
        If($This.Name){

            $this.Path = Join-Path -Path $this.FolderPath -ChildPath ($This.Name + '.ps1')
        }else{
            Throw "Please set a Name first!"
        }
    }

   [Void]CreateFile() {
        If($this.Force){
            New-Item -Path  $this.FolderPath -Name ($this.Name + '.ps1') -force
        }Else{
            New-Item -Path  $this.FolderPath -Name ($this.Name + '.ps1')
        }

    }

    Create(){
        Throw "must ne overwritten!"
    }

}

Class PolarisRoute : PsWebRoute {

    Create (){
$Content = @"
New-PolarisRoute -Type '$($this.RouteType)' -Path '$($this.RoutePath)' -ScriptBlock {
    $($this.ScriptBlock)
}
"@


        $This.CreateFile()
       Out-File -filePath $this.Path.FullName -InputObject $Content
    }
}

Class UniversalDashBoardRoute : PsWebRoute {

    Create (){
    $Content = @"
New-UDEndPoint -Method '$($this.RouteType)' -Url '$($this.RoutePath)' -EndPoint {
    $($this.ScriptBlock)
}
"@
        
    $This.CreateFile()
        Out-File -filePath $this.Path.FullName -InputObject $Content
    }
}

Function New-PSWebRouteFile {
    [String]$RoutePath,
    [RouteType]$RouteType = [RouteType]::GET
    $ScriptBlock



}

New-PsWebPRoject -Path .\devtest -Name "eee"

$e = [PolarisRoute]::New()
$e.Name = 'index'
#$e.SetfolderPath("C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSWeb\Tests\Routes")
$e.RoutePath = "/index"

$e.RouteType = "GET"
$e.ScriptBlock = [ScriptBlock]::Create({Get-Service})
#$e.Create()

$e = [UniversalDashBoardRoute]::New()
$e.Name = 'Upload'
$e.SetfolderPath("C:\Users\taavast3\OneDrive\Repo\Projects\OpenSource\PSWeb\Tests\Routes")
$e.RoutePath = "/Upload"

$e.RouteType = "POST"
$e.ScriptBlock = [ScriptBlock]::Create({Get-Service | Upload-Content})
$e.Create()