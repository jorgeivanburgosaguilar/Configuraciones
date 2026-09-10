# ============================================================
# PowerShell 7 Profile - jorgeburgos
# ============================================================

# --- Prompt: título de ventana + prompt corto ---
function prompt {
    $loc = Get-Location
    try {
        if ($Host.UI.RawUI) {
            $Host.UI.RawUI.WindowTitle = $loc
        }
    } catch {}
    (Split-Path -Leaf $loc) + "> "
}


# --- Paleta One Dark (Atom) ---
$OneDark = @{
    Blue   = $PSStyle.Foreground.FromRgb(0x61AFEF)  # directorios
    Yellow = $PSStyle.Foreground.FromRgb(0xE5C07B)  # symlinks/junctions
    Green  = $PSStyle.Foreground.FromRgb(0x98C379)  # ejecutables
    Cyan   = $PSStyle.Foreground.FromRgb(0x56B6C2)  # scripts PS
    Purple = $PSStyle.Foreground.FromRgb(0xC678DD)  # datos estructurados
    Red    = $PSStyle.Foreground.FromRgb(0xE06C75)  # archivos comprimidos
    Fg     = $PSStyle.Foreground.FromRgb(0xABB2BF)  # foreground suave
    Orange = $PSStyle.Foreground.FromRgb(0xD19A66)  # código fuente
    Gray   = $PSStyle.Foreground.FromRgb(0x5C6370)  # artefactos y ruido
}

# --- $PSStyle.FileInfo: colores One Dark para Get-ChildItem / ls / l / la ---
$PSStyle.FileInfo.Directory    = $OneDark.Blue + $PSStyle.Bold
$PSStyle.FileInfo.SymbolicLink = $OneDark.Yellow
$PSStyle.FileInfo.Executable   = $OneDark.Green

# Scripts y config de PowerShell
$PSStyle.FileInfo.Extension['.ps1']    = $OneDark.Cyan
$PSStyle.FileInfo.Extension['.psm1']   = $OneDark.Cyan
$PSStyle.FileInfo.Extension['.psd1']   = $OneDark.Cyan
$PSStyle.FileInfo.Extension['.ps1xml'] = $OneDark.Cyan

# Datos estructurados
$PSStyle.FileInfo.Extension['.json'] = $OneDark.Purple
$PSStyle.FileInfo.Extension['.xml']  = $OneDark.Purple
$PSStyle.FileInfo.Extension['.yaml'] = $OneDark.Purple
$PSStyle.FileInfo.Extension['.yml']  = $OneDark.Purple

# Documentación
$PSStyle.FileInfo.Extension['.md']  = $OneDark.Fg
$PSStyle.FileInfo.Extension['.txt'] = $OneDark.Fg
$PSStyle.FileInfo.Extension['.docx'] = $OneDark.Fg

# Archivos comprimidos
$PSStyle.FileInfo.Extension['.zip'] = $OneDark.Red
$PSStyle.FileInfo.Extension['.7z']  = $OneDark.Red
$PSStyle.FileInfo.Extension['.tar'] = $OneDark.Red
$PSStyle.FileInfo.Extension['.gz']  = $OneDark.Red
$PSStyle.FileInfo.Extension['.rar'] = $OneDark.Red

# Código fuente
foreach ($e in '.ts','.tsx','.js','.jsx','.mjs','.cjs','.py','.cs','.go','.rs',
               '.java','.rb','.php','.vue','.svelte','.sql','.html','.css','.scss','.sh') {
    $PSStyle.FileInfo.Extension[$e] = $OneDark.Orange
}

# Configuración
foreach ($e in '.toml','.ini','.cfg','.conf','.env','.csv',
               '.gitignore','.gitattributes','.editorconfig','.dockerignore') {
    $PSStyle.FileInfo.Extension[$e] = $OneDark.Purple
}

# Artefactos de build y ruido
foreach ($e in '.log','.lock','.tmp','.cache','.map','.dll','.pdb','.obj','.lib','.bak') {
    $PSStyle.FileInfo.Extension[$e] = $OneDark.Gray
}

# --- Funciones ---
function Format-FileSize {
    param([long]$Bytes)

    if ($Bytes -lt 1024) { return "$Bytes" }

    $units = @('K','M','G','T','P')
    $size  = [double]$Bytes
    $i     = -1
    while ($size -ge 1024 -and $i -lt ($units.Count - 1)) {
        $size = $size / 1024
        $i++
    }

    if ($size -lt 10) { '{0:0.0}{1}' -f $size, $units[$i] }
    else              { '{0:0}{1}'   -f $size, $units[$i] }
}

function Get-FileStyle {
    param($Item)

    if ([Console]::IsOutputRedirected) { return '' }
    if ($Item.PSIsContainer)           { return $PSStyle.FileInfo.Directory }
    if ($Item.LinkType)                { return $PSStyle.FileInfo.SymbolicLink }

    $ext = $Item.Extension
    if ($ext) {
        if ($PSStyle.FileInfo.Extension.ContainsKey($ext)) { return $PSStyle.FileInfo.Extension[$ext] }
        if (($env:PATHEXT -split ';') -contains $ext)      { return $PSStyle.FileInfo.Executable }
    }
    return ''
}

function Show-FileListing {
    param($Items)

    $dim   = if ([Console]::IsOutputRedirected) { '' } else { $OneDark.Gray }
    $reset = if ($dim) { $PSStyle.Reset } else { '' }

    $Items | Format-Table -AutoSize -Property @(
        @{ Label = 'Mode'; Expression = { $_.Mode } }
        @{ Label = 'Size'; Expression = { if ($_.PSIsContainer) { '' } else { Format-FileSize $_.Length } }
           Alignment = 'Right' }
        @{ Label = 'Modificado'; Expression = { '{0:yyyy-MM-dd HH:mm}' -f $_.LastWriteTime } }
        @{ Label = 'Nombre'; Expression = {
            $style = Get-FileStyle $_
            $name  = if ($style) { $style + $_.Name + $PSStyle.Reset } else { $_.Name }
            if ($_.LinkTarget) { "$name $dim-> $($_.LinkTarget)$reset" } else { $name }
        }}
    )

    $files = @($Items | Where-Object { -not $_.PSIsContainer })
    $dirs  = @($Items | Where-Object { $_.PSIsContainer })
    $total = [long](($files | Measure-Object -Property Length -Sum).Sum)

    "$dim{0} archivos, {1} carpetas, {2} en total$reset" -f $files.Count, $dirs.Count, (Format-FileSize $total)
}

function l {
    Show-FileListing @(Get-ChildItem @Args)
}

function la {
    Show-FileListing @(Get-ChildItem -Force @Args)
}

$DevelopmentRoot = "D:\Desarrollo"

function cddev {
    param(
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        Set-Location $DevelopmentRoot
        return
    }

    $destination = [System.IO.Path]::GetFullPath(
        [System.IO.Path]::Combine($DevelopmentRoot, $Path)
    )
    $allowedPrefix = $DevelopmentRoot + [System.IO.Path]::DirectorySeparatorChar

    if ($destination -ne $DevelopmentRoot -and
        -not $destination.StartsWith($allowedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-Host "La ruta debe estar dentro de $DevelopmentRoot." -ForegroundColor Red
        return
    }

    if (-not (Test-Path -LiteralPath $destination -PathType Container)) {
        Write-Host "La ruta '$($destination.TrimEnd([System.IO.Path]::DirectorySeparatorChar))' no existe o no es un directorio." -ForegroundColor Red
        return
    }

    Set-Location $destination
}

Register-ArgumentCompleter -CommandName cddev -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $word = $wordToComplete.Trim("'", '"')

    Get-ChildItem -Path (Join-Path $DevelopmentRoot "$word*") -Directory -ErrorAction SilentlyContinue |
        ForEach-Object {
            $relative = $_.FullName.Substring($DevelopmentRoot.Length + 1)
            $text = if ($relative -match '\s') { "'$relative'" } else { $relative }
            [System.Management.Automation.CompletionResult]::new(
                $text, $relative, 'ParameterValue', $_.FullName
            )
        }
}

function gitstatus {
    $root = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "No estas dentro de un repositorio git." -ForegroundColor Red
        return
    }
    $root = ([string]$root).Trim().Replace('/', [IO.Path]::DirectorySeparatorChar)

    $prev = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [Text.Encoding]::UTF8
        $lines = @(git -c core.quotepath=false status -s)
    }
    finally {
        [Console]::OutputEncoding = $prev
    }

    if ($lines.Count -eq 0) {
        Write-Host "Git: Sin cambios." -ForegroundColor DarkGray
        return
    }

    $entries = foreach ($line in $lines) {
        $path = $line.Substring(3)
        if ($path -match '^(.*) -> (.*)$') { $path = $Matches[2] }
        [PSCustomObject]@{
            Code = $line.Substring(0, 2)
            Path = $path.Trim('"')
        }
    }

    $width = (@($entries.Path) | Measure-Object -Property Length -Maximum).Maximum

    foreach ($e in $entries) {
        $code  = $e.Code
        $color = switch -Regex ($code) {
            '\?' { 'Green';  break }
            'D'  { 'Red';    break }
            'R'  { 'Cyan';   break }
            'A'  { 'Green';  break }
            'M'  { 'Yellow'; break }
            default { 'Gray' }
        }

        $stamp = ''
        if ($code -notmatch 'D') {
            $item = Get-Item -LiteralPath (Join-Path $root $e.Path.Replace('/', [IO.Path]::DirectorySeparatorChar)) -Force -ErrorAction SilentlyContinue
            if ($item) { $stamp = "  ({0:yyyy-MM-dd HH:mm})" -f $item.LastWriteTime }
        }

        Write-Host ("{0} {1}{2}" -f $code, $e.Path.PadRight($width), $stamp) -ForegroundColor $color
    }
}

function scoup {
    scoop update
    scoop status
}

# --- Aliases ---
Set-Alias ~ $HOME

# --- Autocomplete ---
Set-PSReadLineKeyHandler -Chord "F2" -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Chord "RightArrow" -Function ForwardWord
