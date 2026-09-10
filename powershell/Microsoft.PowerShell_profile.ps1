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
    Orange = $PSStyle.Foreground.FromRgb(0xD19A66)  # acento (no usado aún)
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

# --- Funciones ---
function l {
    Get-ChildItem @Args | Format-Table -AutoSize
}

function la {
    Get-ChildItem -Force @Args | Format-Table -AutoSize
}

function cddev {
    param(
        [string]$Path
    )

    $developmentRoot = "D:\Desarrollo"

    if ([string]::IsNullOrWhiteSpace($Path)) {
        Set-Location $developmentRoot
        return
    }

    $destination = [System.IO.Path]::GetFullPath(
        [System.IO.Path]::Combine($developmentRoot, $Path)
    )
    $allowedPrefix = $developmentRoot + [System.IO.Path]::DirectorySeparatorChar

    if ($destination -ne $developmentRoot -and
        -not $destination.StartsWith($allowedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "La ruta debe estar dentro $developmentRoot."
    }

    Set-Location $destination
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
