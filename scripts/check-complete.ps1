# Check if all phases in task_plan.md are complete
# Exit 0 if complete, exit 1 if incomplete
# Used by Stop hook to verify task completion

param(
    [string]$PlanFile = "task_plan.md"
)

if (-not (Test-Path $PlanFile)) {
    Write-Host "ERROR: $PlanFile not found"
    Write-Host "Cannot verify completion without a task plan."
    exit 1
}

Write-Host "=== Task Completion Check ==="
Write-Host ""

# Read file content
$content = Get-Content $PlanFile -Raw

# Count total phases
$TOTAL = ([regex]::Matches($content, "### Phase")).Count

# Check for **Status:** format first
$COMPLETE = ([regex]::Matches($content, "\*\*Status:\*\* complete")).Count
$IN_PROGRESS = ([regex]::Matches($content, "\*\*Status:\*\* in_progress")).Count
$PENDING = ([regex]::Matches($content, "\*\*Status:\*\* pending")).Count

# Fallback: check for [complete] inline format if **Status:** not found
if ($COMPLETE -eq 0 -and $IN_PROGRESS -eq 0 -and $PENDING -eq 0) {
    $COMPLETE = ([regex]::Matches($content, "\[complete\]")).Count
    $IN_PROGRESS = ([regex]::Matches($content, "\[in_progress\]")).Count
    $PENDING = ([regex]::Matches($content, "\[pending\]")).Count
}

Write-Host "Total phases:   $TOTAL"
Write-Host "Complete:       $COMPLETE"
Write-Host "In progress:    $IN_PROGRESS"
Write-Host "Pending:        $PENDING"
Write-Host ""

# Check completion
if ($COMPLETE -eq $TOTAL -and $TOTAL -gt 0) {
    Write-Host "ALL PHASES COMPLETE"
    exit 0
} else {
    Write-Host "TASK NOT COMPLETE"
    Write-Host ""
    Write-Host "Do not stop until all phases are complete."
    exit 1
}
