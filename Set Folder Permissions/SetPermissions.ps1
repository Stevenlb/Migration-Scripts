<#- 
This script will need to have variables updated to reflect your setup. It also depends on a csv file in the location specified for that variable below. 
-#>

#Set Variables
$SiteURL = "https://tenantnamehere.sharepoint.com/sites/SiteName"
$CSVFile = "C:\Temp\PermissionsMatrix.csv"
 
Try {
    #Connect to site
    Connect-PnPOnline -Url $SiteURL -Interactive # or -UseWeb
 
    #Import Matrix
    $CSVData = Import-CSV $CSVFile
  
    #Set Permissions
    ForEach($Row in $CSVData)
    {
        Try {
            #Read Permission
            $Folder = Get-PnPFolder -Url $Row.FolderServerRelativeURL -Includes ListItemAllFields.ParentList -ErrorAction Stop
            $List =  $Folder.ListItemAllFields.ParentList
            $Users =  $Row.Users -split ";"
            ForEach($User in $Users)
            {
                #Set Permission
                Set-PnPFolderPermission -List $List -Identity $Folder.ServerRelativeUrl -User $User.Trim() -AddRole $Row.Permission -ErrorAction Stop
                Write-host -f Green "Set Permissions on Folder '$($Row.FolderServerRelativeURL)' to '$($User.Trim())'"
            }
        }
        Catch {
            Write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
        }
    }
}
Catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}