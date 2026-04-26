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
function la {
    Get-ChildItem -Force @Args
}

function cddev {
    Set-Location "D:\Desarrollo\"
}

# --- Aliases ---
Set-Alias l Get-ChildItem

# --- Autocomplete ---
Set-PSReadLineKeyHandler -Chord "F2" -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Chord "RightArrow" -Function ForwardWord