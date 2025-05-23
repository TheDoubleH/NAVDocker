# INPUT
#     $runPath
#
# OUTPUT
#     $certificateCerFile (if self signed)
#     $certificateThumbprint
#     $dnsIdentity
#
. (Get-MyFilePath "New-SelfSignedCertificateEx.ps1")

Write-Host "Creating Self Signed Certificate"
$certificatePfxFile = Join-Path $runPath "certificate.pfx"
$certificateCerFile = Join-Path $runPath "certificate.cer"
$certificatePfxPassword = Get-RandomPassword
$SecurePfxPassword = ConvertTo-SecureString -String $certificatePfxPassword -AsPlainText -Force
New-SelfSignedCertificateEx -Subject "CN=$publicDnsName" -SubjectAlternativeName @($publicDnsName) -IsCA $true -Exportable -Path $certificatePfxFile -Password $SecurePfxPassword -SignatureAlgorithm sha256 | Out-Null
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certificatePfxFile, $certificatePfxPassword)
Export-Certificate -Cert $cert -FilePath $CertificateCerFile | Out-Null
$certificateThumbprint = $cert.Thumbprint
Write-Host "Self Signed Certificate Thumbprint $certificateThumbprint"
Import-PfxCertificate -Password $SecurePfxPassword -FilePath $certificatePfxFile -CertStoreLocation "cert:\localMachine\my" | Out-Null
Import-PfxCertificate -Password $SecurePfxPassword -FilePath $certificatePfxFile -CertStoreLocation "cert:\localMachine\Root" | Out-Null
$dnsidentity = $cert.GetNameInfo('SimpleName',$false)

Write-Host "Setting Tls12"
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -name "SchUseStrongCrypto" -value 00000001
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
Write-Host "Tls12 Enabled"
