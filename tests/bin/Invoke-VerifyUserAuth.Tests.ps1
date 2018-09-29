$script:ModuleName = 'RestPS'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

function Write-Output {}
function Invoke-VerifySubject {}
function Get-RestUserAuth {}
$tempDir = (pwd).Path
$RestPSLocalRoot = $tempDir + "/RestPS" 

Describe "Routes Variable function for $script:ModuleName" {
    $script:ClientCert = $null
    It "Should Return false if a client cert is not found." {
        Mock -CommandName 'Write-Output' -MockWith {}
        Invoke-VerifyUserAuth | Should be $false
        Assert-MockCalled -CommandName 'Write-Output' -Times 1 -Exactly
    }
    It "Should Return false if Invoke-VerifySubject Fails." {
        $script:ClientCert = @{Thumbprint = "123456789"}
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Invoke-VerifySubject' -MockWith {
            $false
        }
        Invoke-VerifyUserAuth | Should be $false
        Assert-MockCalled -CommandName 'Write-Output' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-VerifySubject' -Times 1 -Exactly
    }
    It "Should Return false if No User data is returned from Get-RestUserAuth function." {
        $script:ClientCert = @{Thumbprint = "123456789"}
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Invoke-VerifySubject' -MockWith {
            $true
        }
        Mock -CommandName 'Get-RestUserAuth' -MockWith {
            $RawReturn = @{
                UserData = $null
            }               
            $ReturnJson = $RawReturn | ConvertTo-Json
            $UserAuth = $ReturnJson | convertfrom-json
            return $UserAuth
        }
        Invoke-VerifyUserAuth | Should be $false
        Assert-MockCalled -CommandName 'Write-Output' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-VerifySubject' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-RestUserAuth' -Times 1 -Exactly
    }

    #### Need a way to fake out the $script:Request
    #It "Should Return false if " {
    #    $script:ClientCert = @{Thumbprint = "123456789"}
    #    $RawReturn = @{
    #        Subject    = "cn=client"
    #        Thumbprint = "123456789"
    #        Headers    = @{
    #            Authorization = @{
    #                value = '2.5.29.35'
    #            }
    #        }
    #    }               
    #    $ReturnJson = $RawReturn | ConvertTo-Json
    #    $script:Request = $ReturnJson | convertfrom-json
    #    $script:Subject = "Client"
    #    Mock -CommandName 'Write-Output' -MockWith {}
    #    Mock -CommandName 'Invoke-VerifySubject' -MockWith {
    #        $true
    #    }
    #    Mock -CommandName 'Get-RestUserAuth' -MockWith {
    #        $UserAuth = @{
    #            UserData = @(
    #                @{
    #                    UserName         = 'RestServer'
    #                    SystemAuthString = 'abcd'
    #                },
    #                @{
    #                    UserName         = 'Client'
    #                    SystemAuthString = '1234'
    #                },
    #                @{
    #                    UserName         = 'DemoClient.PowerShellDemo.io'
    #                    SystemAuthString = 'abcd1234'
    #                }
    #            )
    #        }
    #        $UserAuth
    #        return $UserAuth
    #    }
    #    Invoke-VerifyUserAuth | Should be $false
    #    Assert-MockCalled -CommandName 'Write-Output' -Times 4 -Exactly
    #    Assert-MockCalled -CommandName 'Invoke-VerifySubject' -Times 3 -Exactly
    #    Assert-MockCalled -CommandName 'Get-RestUserAuth' -Times 2 -Exactly
    #}
}