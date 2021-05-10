function ConvertTo-EncodedScript
{
  param
  (
    $Path,
    
    [Switch]$Open
  )
  
  $Code = Get-Content -Path $Path -Raw
  $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Code) 
  $Base64 = [Convert]::ToBase64String($Bytes) 
  
  $NewPath = [System.IO.Path]::ChangeExtension($Path, '.pse1')
  $Base64 | Set-Content -Path $NewPath

  if ($Open) { notepad $NewPath }
}