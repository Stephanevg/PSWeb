import-module .\PSWeb -Force



#Load / import an existing pswebsite
$Site = Import-PsWebSite -Path "C:\Users\Stephane\Code\HatchingPS\Woop\"

#Displays the PsWebSite Object
$Site


#List all SitePage Items
$Site.GetSitePageItems()

#Retrieves a specific SitePageItem by ID
$site.GetSitePageItemById("plop")

$VerbosePreference = "Continue"

$site.GetSiteConfigFileByName("team")

[System.Io.Path]::GetRelativePath($Site.SiteConfigsPath.FullName,$site.SiteConfigs[-1].Path.FullName)

$SitePage = [SitePageFile]::New("C:\Users\Stephane\Code\HatchingPS\Woop\SiteInputs\about.ps1")
$SiteConfig = [SitePageConfigFile]::New("C:\Users\Stephane\Code\MTG-Strasbourg\website\Inputs\about.json")

#Creation base site

New-SbSite -Path $Path -force #Creates base site with basic scaffolding

#grabs existing site.
$Site = Get-SBSite 

<#
PS C:\Users\Stephane\Code\HatchingPS> Get-SBSite | fl

FolderPath : C:\Users\Stephane\Code\HatchingPS\woop\
SiteData   : @{inputs=System.Collections.Hashtable; outputs=System.Collections.Hashtable; bin=System.Collections.Hashtable}
#>

#$Site.SiteData | fl

<#
PS C:\Users\Stephane\Code\HatchingPS> Get-SBSiteConfigurationData -Path ./woop/

FolderPath                              SiteData
----------                              --------
C:\Users\Stephane\Code\HatchingPS\woop\ @{inputs=System.Collections.Hashtable; outputs=System.Collections.Hashtable; bin=System.Collections.Hashtable}

#>



Get-SBSiteConfigurationData -Path ./woop/

Function Get-HTSite {

}

