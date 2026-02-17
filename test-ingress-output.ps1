#!/usr/bin/env pwsh
# Test to verify helm template output matches expected behavior

$ErrorActionPreference = "Stop"

Write-Host "Testing Helm template output..." -ForegroundColor Cyan

# Create test values
$testValues = @"
environment: test

ingress:
  enable: true
  host: indefrysning-users.test.ok.dk
  cluster: "Gen 2"
  wwwRedirect: true
  sslRedirect: true
deployment:
  replicas: 1
  container:
    image: europe-west3-docker.pkg.dev/knp-usermanagement-prod/usermanagement/user-management-portal
    tag: "20260129.1"
    containerPort: 80
service:
  enable: true
"@

$testValues | Out-File -FilePath "test-values.yaml" -Encoding utf8

# Run helm template
Write-Host "Running helm template..." -ForegroundColor Yellow
$output = helm template release-name charts/simple-deployment -f test-values.yaml 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Helm template failed" -ForegroundColor Red
    Write-Host $output
    Remove-Item test-values.yaml
    exit 1
}

# Count ingress rules
$ingressRuleCount = ($output | Select-String -Pattern "^\s+- host:" -AllMatches).Matches.Count

Write-Host "`nTest Results:" -ForegroundColor Cyan
Write-Host "  Ingress rules generated: $ingressRuleCount" -ForegroundColor White

# Verify expectations
$testsPassed = $true

if ($ingressRuleCount -ne 1) {
    Write-Host "  ❌ FAIL: Expected 1 ingress rule, got $ingressRuleCount" -ForegroundColor Red
    $testsPassed = $false
} else {
    Write-Host "  ✓ PASS: Single ingress rule generated" -ForegroundColor Green
}

# Check for main host
if ($output -match "host: indefrysning-users.test.ok.dk") {
    Write-Host "  ✓ PASS: Main host found in rules" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: Main host not found in rules" -ForegroundColor Red
    $testsPassed = $false
}

# Check TLS hosts (should have both main and www)
$tlsHosts = ($output | Select-String -Pattern '^\s+- (indefrysning-users\.test\.ok\.dk|"www\.indefrysning-users\.test\.ok\.dk")' -AllMatches).Matches.Count
if ($tlsHosts -eq 2) {
    Write-Host "  ✓ PASS: Both hosts in TLS section" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAIL: Expected 2 TLS hosts, got $tlsHosts" -ForegroundColor Red
    $testsPassed = $false
}

# Cleanup
Remove-Item test-values.yaml

if ($testsPassed) {
    Write-Host "`n✓ All tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n✗ Some tests failed!" -ForegroundColor Red
    exit 1
}
