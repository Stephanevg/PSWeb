#ipmo "C:\Users\Stephane\Code\HatchingPS\SiteBirth\SiteBirth.psm1" -Force
$Path = "C:\Users\Stephane\Code\HatchingPS\woop\"
#Import-SBSite -Path $Path


Class Site {
    [System.IO.DirectoryInfo]$SitePath
    [System.IO.DirectoryInfo]$SiteConfigsPath
    [System.IO.DirectoryInfo]$SiteInputsPath
    [System.IO.DirectoryInfo]$SitePagesPath
    [object[]]$SiteConfigs = @() #Contains config.json files with site speicifics 
    [Object[]]$SiteInputs = @() # Contains the PSHTML code to generate the html files
    [Object[]]$SitePages = @() #Array of generated HTML files (based on the pshtml files + config)
    [System.Collections.Generic.List[SitePageItem]] $SitePageItems = [System.Collections.Generic.List[SitePageItem]]::new()

    Site([System.IO.DirectoryInfo]$Path){
        $this.SitePath = $Path
        $this.SiteConfigsPath = join-Path -Path $this.SitePath.FullName -ChildPath "SiteConfigs"
        $this.SiteInputsPath = join-Path -Path $this.SitePath.FullName -ChildPath "SiteInputs"
        $this.SitePagesPath = join-Path -Path $this.SitePath.FullName -ChildPath "SitePages"
        $this.LoadSiteConfigs()
        $this.LoadSiteInputs()
        $this.LoadSitePages()
        $this.LoadSiteItems()
    }

    [System.IO.DirectoryInfo] GetSiteInputsPath(){
        Return $this.SiteInputsPath
    }

    [System.IO.DirectoryInfo] GetSiteConfigsPath(){
        Return $this.SiteConfigsPath
    }

    [System.IO.DirectoryInfo] GetSitePagesPath(){
        Return $this.SitePagesPath
    }

    [void]LoadSiteItems(){
        

  
        $SiteSourcesPath = $This.GetSiteInputsPath()
        #$ConfigPath = $this.GetSiteConfigsPath()
        #$SitePages = $this.GetSitePagesPath()

        $SourceFiles = Get-ChildItem -Path $SiteSourcesPath.FullName

        foreach($SourceFile in $SourceFiles){
            $SiteItem = [SitePageItem]::New()
            write-verbose "$($SourceFile)"
            $PageSourceFile = [SitePageSourceFile]::New($SourceFile.FullName)
            
            $RelPath = [System.Io.Path]::GetRelativePath($SiteSourcesPath.FullName,$SourceFile.FullName)
            $PageSourceFile.SetRelativePath($RelPath)
            $PotentialConfigRelPath = $RelPath.Replace(".ps1",".json")
            $configFile = $this.GetSiteConfigFileByRelativePath($PotentialConfigRelPath)
            if($configFile){
                $PageSourceFile.SetConfigFile($configFile)
            }
           
            $SiteItem.SetSourceFile($PageSourceFile)
            

            #Fetch config file

            $ConfigFile = Get-ChildItem -Path $this.SiteConfigsPath.FullName | ? {$_.BaseName -eq $SourceFile.BaseName }

            If($configFile){
                #ConfigFile found
                $PageConfigFileItem = [SitePageConfigFile]::New($ConfigFile.FullName)
                $RelPath = [System.Io.Path]::GetRelativePath($this.SiteConfigsPath.FullName,$ConfigFile.FullName)
                $PageConfigFileItem.SetRelativePath($RelPath)

                $SiteItem.SetConfigFile($PageConfigFileItem)
            }else{
                Write-Verbose "[plop] No configFile for $($Sourcefile.Name)"
            }

            #Fetch rendered file

            $RenderedFile = Get-ChildItem -Path $this.SitePagesPath | ? {$_.BaseName -eq $SourceFile.BaseName }

            if($RenderedFile){
                $RenderedFileItem = [SitePageRenderedFile]::New($RenderedFile.FullName)
                write-verbose "[RenderedFile] $($RenderedFile.Name) Found!"
                
                $RelPath = [System.Io.Path]::GetRelativePath($this.SitePagesPath.FullName,$SourceFile.FullName)
                $RenderedFileItem.SetRelativePath($RelPath)

                $SiteItem.SetRenderedFile($RenderedFileItem)
            }

            #$SiteItem.SetId()
            $this.AddSitePageItem($SiteItem)

            
        }

    }

    [void] hidden  LoadSitePages(){
        $pp = $this.GetSitePagesPath()
        $AllPages = Get-ChildItem -Path $pp.FullName

        foreach($Page in $AllPages){
            write-verbose "[SitePage]$($Page)"
            $sp = [SitePageRenderedFile]::New($Page.FullName)
            $RelPath = [System.Io.Path]::GetRelativePath($this.SitePagesPath.FullName,$Page.FullName)
            $sp.SetRelativePath($RelPath)
            $this.SitePages += $sp
        }
    }

    [void] hidden  LoadSiteConfigs(){
        $ConfigPath = $this.GetSiteConfigsPath()
        $AllConfigs = Get-ChildItem -Path $ConfigPath.FullName -Recurse -File

        foreach($ConfigFile in $AllConfigs){
            write-verbose "$($ConfigFile)"
            $spcf = [SitePageConfigFile]::New($ConfigFile.FullName)
            $RelPath = [System.Io.Path]::GetRelativePath($this.SiteConfigsPath.FullName,$ConfigFile.FullName)
            $spcf.SetRelativePath($RelPath)
            $this.SiteConfigs += $spcf
        }
    }

    [void] LoadSiteInputs(){
        $InputsPath = $This.GetSiteInputsPath()
        $items = Get-ChildItem -Path $InputsPath.FullName

        foreach($item in $items){
            write-verbose "$($Item)"
            $sif = [SitePageSourceFile]::New($item.FullName)
            
            $RelPath = [System.Io.Path]::GetRelativePath($this.SiteInputsPath.FullName,$item.FullName)
            $sif.SetRelativePath($RelPath)
            $PotentialConfigRelPath = $RelPath.Replace(".ps1",".json")
            $configFile = $this.GetSiteConfigFileByRelativePath($PotentialConfigRelPath)
            if($configFile){
                $sif.SetConfigFile($configFile)
            }
            $this.SiteInputs += $sif

            
        }


    }

    [SitePageConfigFile] GetSiteConfigFileByName([String]$Name){

        Return $this.SiteConfigs | ? {$_.Name -eq $Name} 
        
    }

    [SitePageConfigFile]GetSiteConfigFileByRelativePath([String]$RelativePath){
        Return $this.SiteConfigs | ? {$_.RelativePath -eq $RelativePath}
    }

    [void]Render(){
        #This method shall render / create the website pages based on what is contained in the SiteInputs folder.
        #This should be language agnostic (Support for PSHTML only at the moment)
    }

    AddSitePageItem($SitePageItem){
        $this.SitePageItems.add($SitePageItem)
    }
    
    [System.Collections.Generic.List[SitePageItem]] GetSitePageItems(){
        return $this.SitePageItems
    }

    [SitePageItem] GetSitePageItemById([String]$id){
        return $this.SitePageItems | ? {$_.Id -eq $id}
    }
}

Class SitePageItem {
    $id
    [SitePageRenderedFile]$RenderedFile
    [SitePageSourceFile]$SourceFile
    [SitePageConfigFile]$ConfigFile

    SitePageItem(){}

    SetRenderedFile([SitePageRenderedFile]$RenderedFile){
        $This.RenderedFile = $RenderedFile
        $this.id = $this.RenderedFile.name
    }

    SetSourceFile([SitePageSourceFile]$SourceFile){
        $This.SourceFile = $SourceFile
        $this.id = $this.SourceFile.name
    }

    SetConfigFile([SitePageconfigfile]$ConfigFile){
        $this.ConfigFile = $ConfigFile
        $this.id = $this.ConfigFile.name
    }

}

Class PSWebSitePageFile {
    #Parent class of all PSWebFiles
    [String]$name
    [System.IO.FileInfo]$Path
    [string]$RelativePath
}

Class SitePageRenderedFile : PSWebSitePageFile {
    [String]$name
    [System.IO.FileInfo]$Path
    [Object]$PageContent
    [bool]$ConfigFilePresent
    [SitePageConfigFile]$config
    [string]$RelativePath

    SitePageRenderedFile([System.IO.FileInfo]$Path){
        if($Path.Exists){
            $this.Path = $Path
            $this.name = $this.Path.BaseName
            $this.PageContent = Get-Content $this.Path -Encoding utf8
        }
        #$pd = $this.Path.Directory
        
        <#
        $pd = ([System.IO.DirectoryInfo] $this.path.FullName).Parent.parent #Going back to root of site
        
        $SiteConfigsFolder = Join-Path -Path $pd.FullName -ChildPath "SiteConfigs"
        $configfileName = "$($this.name)" + ".json"
        $conf = Get-ChildItem -Path $SiteConfigsFolder -Filter $configfileName
        if($conf){
            $this.ConfigFilePresent = $true
            $this.config = [SitePageConfig]::new($conf.FullName)
        }
        #>

    }

    [bool] HasConfigFile(){
        return $This.ConfigFilePresent
        
    }

    [object]GetConfigData(){
        if($this.HasConfigFile()){
            return $this.config.ConfigData
        }else{
            return $null
        }
    }

    [void]SetConfigFile([SitePageConfigFile]$SitePageConfig){
        $this.ConfigFilePresent = $SitePageConfig.Present
        $this.config = $SitePageConfig
    }

    [void]SetRelativePath([String]$RelPath){
        $this.RelativePath = $RelPath
    }

    [String]ToString(){
        Return $this.Path.Name
    }
}


<#
    SitePageSourceFile represents the pshtml files (.ps1) that would render the SitePages (.html files)
#>
#Rename to SiteSourceFile ?
Class SitePageSourceFile : PSWebSitePageFile {
    [String]$name
    [System.IO.FileInfo]$Path
    [Object]$PageContent
    [bool]$ConfigFilePresent
    [SitePageConfigFile]$config
    [String]$RelativePath

    SitePageSourceFile([System.IO.FileInfo]$Path){
        if($Path.Exists){
            $this.Path = $Path
            $this.name = $this.Path.BaseName
            $this.PageContent = Get-Content $this.Path -Encoding utf8
        }
        #$pd = $this.Path.Directory
        
        <#
        $pd = ([System.IO.DirectoryInfo] $this.path.FullName).Parent.parent #Going back to root of site
        
        $SiteConfigsFolder = Join-Path -Path $pd.FullName -ChildPath "SiteConfigs"
        $configfileName = "$($this.name)" + ".json"
        $conf = Get-ChildItem -Path $SiteConfigsFolder -Filter $configfileName
        if($conf){
            $this.ConfigFilePresent = $true
            $this.config = [SitePageConfig]::new($conf.FullName)
        }
        #>

    }

    [bool] HasConfigFile(){
        return $This.ConfigFilePresent
        
    }

    [object]GetConfigData(){
        if($this.HasConfigFile()){
            return $this.config.ConfigData
        }else{
            return $null
        }
    }

    [void]SetConfigFile([SitePageConfigFile]$SitePageConfig){
        $this.ConfigFilePresent = $SitePageConfig.Present
        $this.config = $SitePageConfig
    }

    [void]SetRelativePath([String]$RelPath){
        $this.RelativePath = $RelPath
    }

    [String]ToString(){
        Return $this.Path.Name
    }

    [String] Render(){
        #Renders this individual SitePage
        return ""
    }
}

Class SitePageConfigFile : PSWebSitePageFile {
    [string]$name
    [System.IO.FileInfo]$Path
    [bool]$Present
    [object]$ConfigData #Rename to PageContent for consistency
    [String]$RelativePath
    [bool]$SitePageSourceFilePresent

    SitePageConfigFile([System.IO.FileInfo]$Path){
        $this.Path = $Path
        $this.name = $this.Path.BaseName
        $this.Fetch()
        
    }

    Fetch(){
        $this.Path.Refresh() #Refreshes to the latest state
        if($this.Path.Exists){
            $this.Present = $True
            $this.ConfigData = Get-content -Path $this.path.FullName | ConvertFrom-Json
        }else{
            $this.Present = $false
        }

    }

    [object]GetConfigData(){
        return $this.ConfigData
    }

    [String]ToString(){
        Return $this.Path.Name
    }

    [void]SetRelativePath([String]$RelPath){
        $this.RelativePath = $RelPath
    }
}

Class SitePageConfigFileCollection {
    [System.Collections.Generic.List[SitePageConfigFile]] $SecurityDocuments = [System.Collections.Generic.List[SitePageConfigFile]]::new()


}

function Import-PsWebSite {
    Param(
        [Parameter(Mandatory=$true)]
        [System.IO.DirectoryInfo]$Path
    )
    $script:Site = [Site]::New($Path.FullName)
    return $script:site
}


function Get-PSWebSite {
   
    return $script:Site
}

