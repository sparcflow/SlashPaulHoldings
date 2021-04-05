#
# Original https://github.com/briansworth/AesEncryption/
# with a few adjustments
#

Function NewPasswordKey
{
  [CmdletBinding()]
  Param(
    [String]$Password,

    [String]$Salt
  )
  $saltBytes = [Text.Encoding]::ASCII.GetBytes($Salt)
  $iterations = 1000
  $keySize = 256

  $passwordType = 'Security.Cryptography.Rfc2898DeriveBytes'
  $passwordDerive = New-Object -TypeName $passwordType `
    -ArgumentList @(
      $Password,
      $saltBytes,
      $iterations,
      'SHA256'
    )

  $keyBytes = $passwordDerive.GetBytes($keySize / 8)
  return $keyBytes
}

Class CipherInfo
{
  [String]$CipherText
  [Byte[]]$IV
  [String]$Salt

  CipherInfo([String]$CipherText, [Byte[]]$IV, [String]$Salt)
  {
    $this.CipherText = $CipherText
    $this.IV = $IV
    $this.Salt = $Salt
  }
}

<#
.SYNOPSIS
Encrypt a string using the Advanced Encryption Standard (AES).

.DESCRIPTION
Encrypt a string using the Advanced Encryption Standard (AES).

.PARAMETER String
The string to encrypt.

.PARAMETER Password
The password to use to encrypt your string.

.PARAMETER Salt
The salt used for generating the password key.
You must use the same salt for encryption / decryption.

.PARAMETER Padding
The padding to use for encryption / decryption.
Default is PKCS7.
#>
Function Protect-AesString
{
  [CmdletBinding()]
  Param(
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
    [String]$String,

    [Parameter(Position=1, Mandatory=$true)]
    [String]$Password,

    [Parameter(Position=2)]
    [String]$Salt = 'qtsbp6j643ah8e0omygzwlv9u75xcfrk4j63fdane78w1zgxhucsytkirol0v25q',

    [Parameter(Position=3)]
    [Security.Cryptography.PaddingMode]$Padding = 'PKCS7'
  )
  Try
  {
    $valueBytes = [Text.Encoding]::UTF8.GetBytes($String)
    [byte[]]$keyBytes = NewPasswordKey -Password $Password -Salt $Salt

    $cipher = [Security.Cryptography.SymmetricAlgorithm]::Create('AesManaged')
    $cipher.Mode = [Security.Cryptography.CipherMode]::CBC
    $cipher.Padding = $Padding
    $vectorBytes = $cipher.IV

    $encryptor = $cipher.CreateEncryptor($keyBytes, $vectorBytes)
    $stream = New-Object -TypeName IO.MemoryStream
    $writer = New-Object -TypeName Security.Cryptography.CryptoStream `
      -ArgumentList @(
        $stream,
        $encryptor,
        [Security.Cryptography.CryptoStreamMode]::Write
      )

    $writer.Write($valueBytes, 0, $valueBytes.Length)
    $writer.FlushFinalBlock()
    $encrypted = $stream.ToArray()

    $cipher.Clear()
    $stream.SetLength(0)
    $stream.Close()
    $writer.Clear()
    $writer.Close()
    [Convert]::ToBase64String($vectorBytes + $encrypted)
  }
  Catch
  {
    Write-Error $_
  }
}

<#
.SYNOPSIS
Decrypt a protected string using the Advanced Encryption Standard (AES).

.DESCRIPTION
Decrypt a protected string using the Advanced Encryption Standard (AES).

.PARAMETER String
The string to decrypt.

.PARAMETER Password
The password to use to decrypt your string.

.PARAMETER Salt
The salt used for generating the password key.
You must use the same salt for encryption / decryption.

.PARAMETER InitializationVector
The initialization vector (IV) used for encryption, to use for decryption.

.PARAMETER CipherInfo
The CipherInfo object to use for decryption.
This object is obtained from Protect-AesString.

.PARAMETER Padding
The padding to use for encryption / decryption.
Default is PKCS7.
#>
Function Unprotect-AesString
{
  [CmdletBinding(DefaultParameterSetName='String')]
  Param(
    [Parameter(Position=0, Mandatory=$true, ParameterSetName='String', ValueFromPipeline=$true)]
    [Alias('EncryptedString')]
    [String]$String,

    [Parameter(Position=1, Mandatory=$true)]
    [String]$Password,

    [Parameter(Position=2, ParameterSetName='String')]
    [String]$Salt = 'qtsbp6j643ah8e0omygzwlv9u75xcfrk4j63fdane78w1zgxhucsytkirol0v25q',

    [Security.Cryptography.PaddingMode]$Padding = 'PKCS7'
  )
  Process
  {
    Try
    {
      $rawBytes = [Convert]::FromBase64String($String)
      $iv = $rawBytes[0..15]
      $valueBytes = $rawBytes[16..$rawBytes.length]
      $keyBytes = NewPasswordKey -Password $Password -Salt $Salt

      $cipher = [Security.Cryptography.SymmetricAlgorithm]::Create('AesManaged')
      $cipher.Mode = [Security.Cryptography.CipherMode]::CBC
      $cipher.Padding = $Padding

      $decryptor = $cipher.CreateDecryptor($keyBytes, $iv)
      $stream = New-Object -TypeName IO.MemoryStream `
        -ArgumentList @(, $valueBytes)
      $reader = New-Object -TypeName Security.Cryptography.CryptoStream `
        -ArgumentList @(
          $stream,
          $decryptor,
          [Security.Cryptography.CryptoStreamMode]::Read
        )

      $decrypted = New-Object -TypeName Byte[] -ArgumentList $valueBytes.Length
      $decryptedByteCount = $reader.Read($decrypted, 0, $decrypted.Length)
      $decryptedValue = [Text.Encoding]::UTF8.GetString(
        $decrypted,
        0,
        $decryptedByteCount
      )
      $cipher.Clear()
      $stream.SetLength(0)
      $stream.Close()
      $reader.Clear()
      $reader.Close()
      return $decryptedValue
    }
    Catch
    {
      Write-Error $_
    }
  }
}

