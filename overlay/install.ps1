<#
.SYNOPSIS
  Project-level installer for the intent-overlay governance block.
  Injects / removes / diagnoses the "Intent Overlay (active)" marker block in AGENTS.md.

.PARAMETER Dir
  Project directory that contains AGENTS.md (default: current working directory).

.PARAMETER Uninstall
  Remove the overlay block from AGENTS.md, leaving the rest byte-identical.

.PARAMETER Doctor
  Verify the gentle-ai seams (AGENTS.md present + writable, block installed,
  VISION.md and PHASE-LENS.md present). Exits non-zero on any failure.
#>
param(
    [string]$Dir      = '.',
    [switch]$Uninstall,
    [switch]$Doctor
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Script:BLOCK_START = '<!-- intent-overlay:start -->'
$Script:BLOCK_END   = '<!-- intent-overlay:end -->'

# ---------------------------------------------------------------------------
# Block content
# ---------------------------------------------------------------------------

function Get-InstallBlock {
    <#
    .SYNOPSIS
      Returns the marker block to inject into AGENTS.md as a [string[]].
      Content is verbatim from install.sh block() — do not alter the marker strings.
    #>
    return @(
        $Script:BLOCK_START,
        '## Intent Overlay (active)',
        '',
        'Govern every substantial SDD change with one approved intent and one quality bar — no extra documents.',
        'The intent lives in SDD''s own `proposal`/`spec`/`design`; the human approving the proposal is the',
        'freeze. Trivial or small changes skip SDD: apply clean-code judgment inline and stop.',
        '',
        'Pass these overlay paths to EVERY SDD phase, applied through `overlay/skill/references/PHASE-LENS.md`:',
        '- `overlay/skill/references/VISION.md`',
        '- `overlay/skill/references/PHASE-LENS.md`',
        '',
        'Every phase emits `Intent Gate: aligned | drift-detected`. Code phases also emit the Clean Code Gate',
        'at refactor-exit. `drift-detected` halts the chain and returns to the human as a change request',
        '(a proposal amendment); it is never applied silently.',
        $Script:BLOCK_END
    )
}

# ---------------------------------------------------------------------------
# Block inject / remove / test
# ---------------------------------------------------------------------------

function Invoke-BlockInject {
    <#
    .SYNOPSIS
      Appends Block (preceded by one blank line) to FilePath.
      No-op when the START marker is already present (idempotent).
      Creates parent directories if absent.
    .PARAMETER FilePath
      Absolute path to the target AGENTS.md.
    .PARAMETER Block
      [string[]] of lines to inject (from Get-InstallBlock).
    #>
    param(
        [Parameter(Mandatory)][string]  $FilePath,
        [Parameter(Mandatory)][string[]]$Block
    )

    $parent = Split-Path -Parent $FilePath
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $lines = if (Test-Path $FilePath) { @(Get-Content -LiteralPath $FilePath) } else { @() }

    if ($lines -contains $Script:BLOCK_START) { return }   # idempotent

    Set-Content -LiteralPath $FilePath -Value (@($lines) + @('') + $Block) -Encoding UTF8
}

function Invoke-BlockRemove {
    <#
    .SYNOPSIS
      Removes the marker block (START..END inclusive) and the one preceding blank
      line that Invoke-BlockInject added. Remaining bytes are identical to pre-install
      state. No-op when FilePath does not exist or the START marker is absent.
    .PARAMETER FilePath
      Absolute path to the target AGENTS.md.
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

function Test-BlockPresent {
    <#
    .SYNOPSIS
      Returns $true when FilePath exists and contains the START marker.
    .PARAMETER FilePath
      Absolute path to the file to inspect.
    #>
    param([Parameter(Mandatory)][string]$FilePath)

    if (-not (Test-Path $FilePath)) { return $false }
    return @(Get-Content -LiteralPath $FilePath) -contains $Script:BLOCK_START
}

function Test-Seams {
    <#
    .SYNOPSIS
      Verifies the gentle-ai seams in Dir: AGENTS.md present and writable,
      block installed, VISION.md present, PHASE-LENS.md present.
      Returns 0 on all-pass, 1 on any failure.
    .PARAMETER Dir
      Resolved project root directory path.
    #>
    param([Parameter(Mandatory)][string]$Dir)

    $ok        = $true
    $agents    = Join-Path $Dir 'AGENTS.md'
    $vision    = Join-Path $Dir 'overlay\skill\references\VISION.md'
    $phaseLens = Join-Path $Dir 'overlay\skill\references\PHASE-LENS.md'

    if ((Test-Path $agents -PathType Leaf) -and
        -not ([System.IO.File]::GetAttributes($agents) -band [System.IO.FileAttributes]::ReadOnly)) {
        Write-Host "ok   - AGENTS.md present and writable"
    } else {
        Write-Host "FAIL - AGENTS.md missing or not writable"
        $ok = $false
    }

    if (Test-BlockPresent -FilePath $agents) {
        Write-Host "ok   - overlay block present in AGENTS.md"
    } else {
        Write-Host "FAIL - overlay block missing from AGENTS.md (run install.ps1)"
        $ok = $false
    }

    foreach ($pair in @(
        [pscustomobject]@{ Label = 'VISION.md';     Path = $vision },
        [pscustomobject]@{ Label = 'PHASE-LENS.md'; Path = $phaseLens }
    )) {
        if (Test-Path $pair.Path -PathType Leaf) {
            Write-Host "ok   - $($pair.Label) present"
        } else {
            Write-Host "FAIL - $($pair.Label) missing: $($pair.Path)"
            $ok = $false
        }
    }

    if ($ok) { return 0 } else { return 1 }
}

# ---------------------------------------------------------------------------
# Entry guard — do not execute when dot-sourced.
# ---------------------------------------------------------------------------

if ($MyInvocation.InvocationName -ne '.') {
    $resolved = (Resolve-Path $Dir).Path
    $agentsMd = Join-Path $resolved 'AGENTS.md'

    if ($Doctor) {
        exit (Test-Seams -Dir $resolved)
    } elseif ($Uninstall) {
        Invoke-BlockRemove -FilePath $agentsMd
        Write-Host "Overlay removed from $agentsMd."
    } else {
        Invoke-BlockInject -FilePath $agentsMd -Block (Get-InstallBlock)
        Write-Host "Overlay installed in $agentsMd."
    }
}
