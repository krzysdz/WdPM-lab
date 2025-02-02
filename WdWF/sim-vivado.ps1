param (
	[Parameter(Mandatory, ParameterSetName="SimAll")]
	[switch]$All,

	[Parameter(Mandatory, ParameterSetName="SingleTest")]
	[ArgumentCompleter({
		param ( $commandName,
				$parameterName,
				$wordToComplete,
				$commandAst,
				$fakeBoundParameters )
		if ($wordToComplete) {
			Get-Content -Path "test-list.txt" | Where-Object { $_ -like "$wordToComplete*" }
		} else {
			Get-Content -Path "test-list.txt" | ForEach-Object {$_}
		}
	})]
	[string]$TestName,

	[Parameter()]
	[switch]$SkipCompilation
)

$PARAM_FILE = "testname.txt"
$ALL_TESTS = Get-Content -Path "test-list.txt"

function MyArgumentCompleter{
    param ( $commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters )

	if ($wordToComplete) {
        $ALL_TESTS | Where-Object {
            $_ -like "$wordToComplete*"
        }
    } else {
        $ALL_TESTS.Values | ForEach-Object {$_}
    }
}

if (!$SkipCompilation) {
	./compile-vivado.ps1
}

$failedTests = New-Object System.Collections.Generic.List[string]

function Clean-Sim {
	Remove-Item -ErrorAction Ignore $PARAM_FILE
	Remove-Item -ErrorAction Ignore tr_db.log
	Remove-Item -ErrorAction Ignore xsim.jou
}

function Run-Test {
	param(
		[Parameter(Mandatory)]
		[string]$TestName
	)

	# Writing tesplusarg to file is necessary, because xsim can't read it from command line
	Set-Content -Path $PARAM_FILE -Value "--testplusarg UVM_TESTNAME=$TestName"
	xsim work.tb_top --nolog -R -f $PARAM_FILE | Tee-Object -Variable cmdOutput
	Clean-Sim
	if (!(($cmdOutput -match "(?m)^UVM_ERROR\s*:\s*0\s*$") -and ($cmdOutput -match "(?m)^UVM_FATAL\s*:\s*0\s*$"))) {
		$failedTests.Add($TestName)
	}
}

if ($TestName) {
	Run-Test -TestName $TestName
} elseif ($All) {
	foreach ($test in $ALL_TESTS) {
		Run-Test -TestName $test
	}
}

if ($failedTests.Count) {
	Write-Output "============================================"
	Write-Output "====            TESTS FAILED            ===="
	Write-Output "============================================"
	Write-Output "Failed test count: $($failedTests.Count)"
	Write-Output "Failed tests: $($failedTests | Join-String -Separator ", ")"
} else {
	Write-Output "============================================"
	Write-Output "====              SUCCESS!              ===="
	Write-Output "============================================"
	Write-Output "All tests have passed"
}
