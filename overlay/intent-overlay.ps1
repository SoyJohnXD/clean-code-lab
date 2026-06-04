Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# D7 — Foundation resolution (Option A)
# Resolve lib/platform-windows.ps1 via $env:AGENT_STACK_LIB or a fixed parent path.
$_libDir = if ($env:AGENT_STACK_LIB) { $env:AGENT_STACK_LIB }
           else { Join-Path $PSScriptRoot '..\..\lib' }
$_module = Join-Path $_libDir 'platform-windows.ps1'
if (-not (Test-Path -LiteralPath $_module -PathType Leaf)) {
    Write-Error "intent-overlay: platform-windows.ps1 not found. Set `$env:AGENT_STACK_LIB to the agent-stack lib directory."
    exit 1
}
. $_module

# ===========================================================================
# Constants
# ===========================================================================

$Script:SKILL          = 'intent-overlay'
$Script:STD_SKILL      = 'clean-code-standards'
$Script:SRC            = Join-Path $PSScriptRoot 'skill'
$Script:STD_SRC        = Join-Path $PSScriptRoot '..\skills\clean-code-standards'
$Script:INVARIANTS_SRC = Join-Path $PSScriptRoot 'instructions\INVARIANTS.md'
$Script:BLOCK_START    = '<!-- intent-overlay:start -->'
$Script:BLOCK_END      = '<!-- intent-overlay:end -->'

# ===========================================================================
# Public functions defined in this module:
#   Get-OverlayLinkRoots    — returns [string[]] of four discovery link roots
#   Get-CanonicalPath       — returns canonical skill dir for a given name
#   Get-HostConfigTargets   — returns [hashtable] of three config file paths
#   Install-Skill           — copy skill to canonical + create junctions in present roots
#   Uninstall-Skill         — remove junctions + canonical dir
#   Test-SkillInstalled     — check canonical SKILL.md + junctions in all present roots
#   Get-MarkedBlock         — extract START..END span from INVARIANTS_SRC
#   Invoke-BlockInject      — idempotent block append to a file
#   Invoke-BlockRemove      — remove block + preceding blank line from a file
#   Invoke-HostInstall      — inject block into all three host configs (gated by dir)
#   Invoke-HostUninstall    — remove block from all three host configs
#   Show-Usage              — print subcommand usage and exit 1
#   Invoke-Install          — orchestrate install
#   Invoke-Uninstall        — orchestrate uninstall
#   Invoke-Doctor           — per-skill and per-host diagnostics
#   Invoke-Dispatch         — top-level dispatcher
# ===========================================================================

# ---------------------------------------------------------------------------
# Path helpers
# ---------------------------------------------------------------------------

function Get-OverlayLinkRoots {
    <#
    .SYNOPSIS
      Returns the four skill link roots that receive discovery junctions.
      Only roots that exist on the filesystem should receive a junction — callers
      are responsible for the existence check.
    #>
    return @(
        (Get-AgentStackPath 'claude-skills'),
        (Get-AgentStackPath 'agents-skills'),
        (Get-AgentStackPath 'pi-skills'),
        (Join-Path (Get-AgentStackPath 'opencode-config') 'skills')
    )
}

function Get-CanonicalPath {
    <#
    .SYNOPSIS
      Returns the canonical skill directory path for a given skill name.
      Mirrors bash canonical_of() / hub() — resolves to <codex-root>\skills\<Name>.
    .PARAMETER Name
      Skill name (e.g. 'intent-overlay').
    #>
    param([Parameter(Mandatory)][string]$Name)
    return Join-Path (Get-AgentStackPath 'codex-root') "skills\$Name"
}

function Get-HostConfigTargets {
    <#
    .SYNOPSIS
      Returns a hashtable of the three host config file paths that receive the
      INVARIANTS always-on block. Keys are human-readable labels; values are
      filesystem paths.
    .OUTPUTS
      [hashtable] label -> absolute file path
    #>
    return @{
        'codex'    = Join-Path (Get-AgentStackPath 'codex-root')      'AGENTS.override.md'
        'claude'   = Join-Path (Get-AgentStackPath 'claude-config')    'CLAUDE.md'
        'opencode' = Join-Path (Get-AgentStackPath 'opencode-config')  'AGENTS.md'
    }
}

# ---------------------------------------------------------------------------
# Skill install / uninstall / test
# ---------------------------------------------------------------------------

function Install-Skill {
    <#
    .SYNOPSIS
      Copies a skill directory to the canonical path and creates junctions under
      each present link root. Idempotent: existing valid junctions are not touched.
    .PARAMETER Src
      Source directory containing at least SKILL.md.
    .PARAMETER Name
      Skill name used for the canonical directory and junction names.
    #>
    param(
        [Parameter(Mandatory)][string]$Src,
        [Parameter(Mandatory)][string]$Name
    )

    if (-not (Test-Path (Join-Path $Src 'SKILL.md') -PathType Leaf)) {
        throw "Install-Skill: SKILL.md not found at $Src"
    }

    $canon = Get-CanonicalPath $Name
    New-Item -ItemType Directory -Path $canon -Force | Out-Null
    Copy-Item -Path (Join-Path $Src '*') -Destination $canon -Recurse -Force

    foreach ($root in (Get-OverlayLinkRoots)) {
        if (-not (Test-Path $root -PathType Container)) { continue }
        $link = Join-Path $root $Name
        if (Test-JunctionValid -Path $link -Target $canon) { continue }
        [void](New-Junction -Path $link -Target $canon)
    }
}

function Uninstall-Skill {
    <#
    .SYNOPSIS
      Removes junctions from each present link root, then deletes the canonical
      directory. Safe when junctions or the canonical dir are already absent.
    .PARAMETER Name
      Skill name to uninstall.
    #>
    param([Parameter(Mandatory)][string]$Name)

    $canon = Get-CanonicalPath $Name

    foreach ($root in (Get-OverlayLinkRoots)) {
        $link = Join-Path $root $Name
        if ($null -ne (Get-JunctionTarget -Path $link)) {
            [void](Remove-Junction -Path $link)
        }
    }

    if (Test-Path $canon) { Remove-Item $canon -Recurse -Force }
}

function Test-SkillInstalled {
    <#
    .SYNOPSIS
      Returns $true only when the canonical dir exists, SKILL.md is present inside
      it, and a valid junction exists in every link root that is present on the
      filesystem.
    .PARAMETER Name
      Skill name to test.
    #>
    param([Parameter(Mandatory)][string]$Name)

    $canon = Get-CanonicalPath $Name
    if (-not (Test-Path (Join-Path $canon 'SKILL.md') -PathType Leaf)) { return $false }

    foreach ($root in (Get-OverlayLinkRoots)) {
        if (-not (Test-Path $root -PathType Container)) { continue }
        $link = Join-Path $root $Name
        if (-not (Test-JunctionValid -Path $link -Target $canon)) { return $false }
    }

    return $true
}

# ---------------------------------------------------------------------------
# Block helpers
# ---------------------------------------------------------------------------

function Get-MarkedBlock {
    <#
    .SYNOPSIS
      Reads INVARIANTS.md from the canonical skill location (resolved at runtime)
      and returns the full START..END span as a [string[]].
    .OUTPUTS
      [string[]] lines from BLOCK_START to BLOCK_END inclusive.
    #>
    $canon = Get-CanonicalPath $Script:SKILL
    $src   = Join-Path $canon 'instructions\INVARIANTS.md'

    # Fallback to script-local source (before first install).
    if (-not (Test-Path $src -PathType Leaf)) {
        $src = $Script:INVARIANTS_SRC
    }

    if (-not (Test-Path $src -PathType Leaf)) {
        throw "Get-MarkedBlock: INVARIANTS.md not found at $src"
    }

    $lines  = @(Get-Content -LiteralPath $src)
    $result = [System.Collections.Generic.List[string]]::new()
    $inside = $false

    foreach ($line in $lines) {
        if ($line -eq $Script:BLOCK_START) { $inside = $true }
        if ($inside) { $result.Add($line) }
        if ($line -eq $Script:BLOCK_END -and $inside) { break }
    }

    return $result.ToArray()
}

function Invoke-BlockInject {
    <#
    .SYNOPSIS
      Appends the INVARIANTS block (preceded by one blank line) to FilePath.
      No-op when the START marker is already present (idempotent).
      Creates parent directories if absent.
    .PARAMETER FilePath
      Absolute path to the target file.
    #>
    param([Parameter(Mandatory)][string]$FilePath)

    $parent = Split-Path -Parent $FilePath
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $lines = if (Test-Path $FilePath) { @(Get-Content -LiteralPath $FilePath) } else { @() }

    if ($lines -contains $Script:BLOCK_START) { return }   # idempotent

    $block = Get-MarkedBlock
    Set-Content -LiteralPath $FilePath -Value (@($lines) + @('') + $block) -Encoding UTF8
}

function Invoke-BlockRemove {
    <#
    .SYNOPSIS
      Removes the INVARIANTS block (START..END inclusive) and the one preceding
      blank line that Invoke-BlockInject added. The remaining bytes are identical
      to the pre-inject state.
      No-op when FilePath does not exist or the START marker is absent.
    .PARAMETER FilePath
      Absolute path to the target file.
    #>
    param([Parameter(Mandatory)][string]$FilePath)

    if (-not (Test-Path $FilePath)) { return }

    $lines = @(Get-Content -LiteralPath $FilePath)
    $n = $lines.Count
    $s = -1
    $e = -1

    for ($i = 0; $i -lt $n; $i++) {
        if ($lines[$i] -eq $Script:BLOCK_START -and $s -lt 0) { $s = $i }
        if ($lines[$i] -eq $Script:BLOCK_END   -and $s -ge 0) { $e = $i; break }
    }

    if ($s -lt 0 -or $e -lt 0) { return }

    # Drop the preceding blank line that inject prepended.
    if ($s -gt 0 -and [string]::IsNullOrEmpty($lines[$s - 1])) { $s-- }

    $out = [System.Collections.Generic.List[string]]::new()
    for ($i = 0; $i -lt $n; $i++) {
        if ($i -lt $s -or $i -gt $e) { $out.Add($lines[$i]) }
    }

    Set-Content -LiteralPath $FilePath -Value $out.ToArray() -Encoding UTF8
}

# ---------------------------------------------------------------------------
# Host install / uninstall
# ---------------------------------------------------------------------------

function Invoke-HostInstall {
    <#
    .SYNOPSIS
      Injects the INVARIANTS block into each of the three host config files,
      gated on the parent directory existing on the filesystem.
    #>
    $targets = Get-HostConfigTargets
    foreach ($key in $targets.Keys) {
        $file   = $targets[$key]
        $parent = Split-Path -Parent $file
        if (-not (Test-Path $parent -PathType Container)) { continue }
        Invoke-BlockInject -FilePath $file
    }
}

function Invoke-HostUninstall {
    <#
    .SYNOPSIS
      Removes the INVARIANTS block from each of the three host config files.
      Safe when files are absent or the block is not present.
    #>
    $targets = Get-HostConfigTargets
    foreach ($key in $targets.Keys) {
        Invoke-BlockRemove -FilePath $targets[$key]
    }
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

function Show-Usage {
    Write-Host @'
Usage: intent-overlay.ps1 <command>

  install    Install discovery (canonical skill + junctions) and always-on
             (INVARIANTS block in host configs) for intent-overlay and
             clean-code-standards.

  uninstall  Reverse install: remove instruction blocks, junctions, and the
             canonical skills.

  doctor     Verify canonical skills, junctions, and host always-on blocks.
             Exits non-zero if any required check fails.
'@
    return 1
}

function Invoke-Install {
    Install-Skill -Src $Script:SRC     -Name $Script:SKILL
    Install-Skill -Src $Script:STD_SRC -Name $Script:STD_SKILL
    Invoke-HostInstall
    Write-Host "intent-overlay + clean-code-standards installed (hub: $(Get-CanonicalPath $Script:SKILL))."
}

function Invoke-Uninstall {
    Invoke-HostUninstall
    Uninstall-Skill -Name $Script:SKILL
    Uninstall-Skill -Name $Script:STD_SKILL
    Write-Host "intent-overlay + clean-code-standards removed."
}

function Invoke-Doctor {
    $overallOk = $true

    # Per-skill checks.
    foreach ($name in @($Script:SKILL, $Script:STD_SKILL)) {
        $canon = Get-CanonicalPath $name

        if (Test-Path (Join-Path $canon 'SKILL.md') -PathType Leaf) {
            Write-Host "ok   - $name canonical present"
        } else {
            Write-Host "FAIL - $name canonical missing: $canon"
            $overallOk = $false
        }

        $skillMd = Join-Path $canon 'SKILL.md'
        if ((Test-Path $skillMd -PathType Leaf) -and
            (@(Get-Content -LiteralPath $skillMd) -contains '## Compact Rules')) {
            Write-Host "ok   - $name declares Compact Rules"
        } else {
            Write-Host "FAIL - $name missing Compact Rules"
            $overallOk = $false
        }

        foreach ($root in (Get-OverlayLinkRoots)) {
            if (-not (Test-Path $root -PathType Container)) { continue }
            $link  = Join-Path $root $name
            $canon = Get-CanonicalPath $name
            if (Test-JunctionValid -Path $link -Target $canon) {
                Write-Host "ok   - junction valid: $link"
            } else {
                Write-Host "FAIL - missing or broken junction: $link"
                $overallOk = $false
            }
        }
    }

    # Per-host always-on block checks (warning, not fail, if missing).
    $targets = Get-HostConfigTargets
    foreach ($key in $targets.Keys) {
        $file   = $targets[$key]
        $parent = Split-Path -Parent $file
        if (-not (Test-Path $parent -PathType Container)) { continue }

        if ((Test-Path $file) -and (@(Get-Content -LiteralPath $file) -contains $Script:BLOCK_START)) {
            Write-Host "ok   - $key always-on block present"
        } else {
            Write-Host "warn - $key always-on block missing (run 'install' to add)"
        }
    }

    if ($overallOk) { return 0 } else { return 1 }
}

function Invoke-Dispatch {
    param([string[]]$DispatchArgs)

    $sub = if ($DispatchArgs.Count -gt 0) { $DispatchArgs[0] } else { '' }

    switch ($sub) {
        'install'                          { Invoke-Install;   return 0 }
        'uninstall'                        { Invoke-Uninstall; return 0 }
        'doctor'                           { return (Invoke-Doctor) }
        { $_ -in @('', '-h', '--help') }   { return (Show-Usage) }
        default                            { Show-Usage; return 1 }
    }
}

# ---------------------------------------------------------------------------
# Entry guard — do not execute when dot-sourced.
# ---------------------------------------------------------------------------

if ($MyInvocation.InvocationName -ne '.') { exit (Invoke-Dispatch $args) }
