# .DESCRIPTION
# Ce script est conçu pour analyser la performance des demandes de déplacement MRS.
# Il fournit des statistiques importantes sur la performance pour un ensemble spécifié de statistiques de demande de déplacement.
# De plus, il génère deux fichiers : un pour la liste des échecs et un autre pour les statistiques de chaque déplacement.
# Pour plus d'informations, veuillez consulter http://aka.ms/MailboxMigrationPerfScript ou https://techcommunity.microsoft.com/t5/exchange-team-blog/mailbox-migration-performance-analysis/ba-p/587134
# Vous devez :
# 01- adapter la function "AuthentificationEXO" avec votre propre logique d'identification :
# 02- remplacer $recipientEmails par une list d'emails destinataire du rapport (fichier CSV résumé HTML) doit être envoyé  : ex email d'u groupe Teams
# 03- remplacer $Logfile par l'emplacement du fichier à généré (.CSV et .zip)
# 04- remplacer $Batches par la liste des batch a analyser : cette liste peut être obtenu dynamiquemeent via Get-MigrationBatch 
# 05- remplacer par le nom du serveur SMTP qui envoie le message électronique.
# 06- remplacer $from par l’adresse e-mail de l’expéditeur du rapport.


# Variables
$recipientEmails    = @("rodrigue.yengo@psdaych.re","1d26ab5b.groups.psdaych.re@emea.teams.ms") 
$Logfile            = "D:\Scripts\PsDayCh\#BatchReport\Logs\AnalyzeMoveRequestStats_$(Get-date -f MMdd-hhmmss).txt"
$Batches            = "MigrationService:EXOMigration_27022024-PsDayFR","EXOMigration_27022024-CH"
$from               = "ExchangeOnlineMigration@psdaych.re"
$smtpServer         = "smtp.psdaych24.re"


function ProcessStats([array] $stats, [string] $name, [int] $percentile=90)
{

if($stats.count -eq 0)
{
  return
}

$startTimestamp = ($stats | sort QueuedTimeStamp | select -first 1).QueuedTimeStamp
$lastCompleted = $stats | sort completiontimestamp -Descending | select -First 1
$lastTimestamp = $lastCompleted.completiontimestamp

if($lastTimestamp -eq $null)
{
	$lastSuspended = $stats | sort SuspendedTimestamp -Descending | select -First 1
	$lastTimestamp = $lastCompleted.SuspendedTimestamp
	if($lastTimestamp -eq $null)
	{
		$lastTimestamp = Get-Date 
	}
}

$moveDuration = $lastTimestamp - $startTimestamp
$MoveDurationInTicks = [math]::Truncate(($lastTimestamp - $startTimestamp).Ticks)

$perMoveInfo = $stats  | 
	select alias, TotalInProgressDuration, TotalIdleDuration, OverallDuration,TotalQueuedDuration,TotalDataReplicationWaitDuration,TotalSuspendedDuration, `
	@{Name="SourceProviderDuration"; Expression={$_.Report.SessionStatistics.SourceProviderInfo.TotalDuration + $_.Report.ArchiveSessionStatistics.SourceProviderInfo.TotalDuration}}, `
	@{Name="DestinationProviderDuration"; Expression={$_.Report.SessionStatistics.DestinationProviderInfo.TotalDuration + $_.Report.ArchiveSessionStatistics.DestinationProviderInfo.TotalDuration}}, `
	@{Name="RelinquishedDurationInTicks"; Expression={$_.OverallDuration.Ticks - $(($_.TotalInProgressDuration, $_.TotalQueuedDuration, $_.TotalFailedDuration, $_.TotalSuspendedDuration)|Measure-Object Ticks -Sum).Sum }}, `

	@{Name="TotalStalledDueToCIInTicks"; Expression={$_.TotalStalledDueToCIDuration.Ticks}},
	@{Name="TotalStalledDueToHAInTicks"; Expression={$_.TotalStalledDueToHADuration.Ticks}},
	@{Name="TotalStalledDueToTargetCpuInTicks"; Expression={$_.TotalStalledDueToWriteCpu.Ticks}},
	@{Name="TotalStalledDueToSourceCpuInTicks"; Expression={$_.TotalStalledDueToReadCpu.Ticks}},
	@{Name="TotalStalledDueToMailboxLockedDurationInTicks"; Expression={$_.TotalStalledDueToMailboxLockedDuration.Ticks}},
	@{Name="TotalStalledDueToSourceProxyUnknownInTicks"; Expression={$_.TotalStalledDueToReadUnknown.Ticks}},
	@{Name="TotalStalledDueToTargetProxyUnknownInTicks"; Expression={$_.TotalStalledDueToWriteUnknown.Ticks}},

	@{Name="SourceLatencySampleCount"; Expression={$_.Report.SessionStatistics.SourceLatencyInfo.NumberOfLatencySamplingCalls}},
	@{Name="AverageSourceLatency"; Expression={$_.Report.SessionStatistics.SourceLatencyInfo.Average}},
	@{Name="TotalNumberOfSourceSideRemoteCalls"; Expression={$_.Report.SessionStatistics.SourceLatencyInfo.TotalNumberOfRemoteCalls}},
	@{Name="DestinationLatencySampleCount"; Expression={$_.Report.SessionStatistics.DestinationLatencyInfo.NumberOfLatencySamplingCalls}},
	@{Name="AverageDestinationLatency"; Expression={$_.Report.SessionStatistics.DestinationLatencyInfo.Average}},
	@{Name="TotalNumberOfDestinationSideRemoteCalls"; Expression={$_.Report.SessionStatistics.DestinationLatencyInfo.TotalNumberOfRemoteCalls}},

	@{Name="WordBreaking_TotalTimeProcessingMessagesInTicks"; Expression={$_.Report.SessionStatistics.TotalTimeProcessingMessages.Ticks}},
	@{Name="TotalTransientFailureDurationInTicks"; Expression={$_.TotalTransientFailureDuration.Ticks}},
	@{Name="TotalInProgressDurationInTicks"; Expression={$_.TotalInProgressDuration.Ticks}},
	@{Name="MailboxSizeInMB"; Expression={ (ToMB $_.TotalMailboxSize) + (ToMB (GetArchiveSize -size $_.TotalArchiveSize -flags $_.Flags))}},
	@{Name="TransferredMailboxSizeInMB"; Expression={((ToMB $_.TotalMailboxSize) + (ToMB (GetArchiveSize -size $_.TotalArchiveSize -flags $_.Flags))) * $_.PercentComplete / 100}},
	@{Name="PerMoveRate"; Expression={(((ToKB $_.TotalMailboxSize) + (ToKB (GetArchiveSize -size $_.TotalArchiveSize -flags $_.Flags)))* $_.PercentComplete / 100 /$_.TotalInProgressDuration.TotalSeconds) * 3600 / 1024}},
  @{Name="BytesTransferredInMB"; Expression={ToMB $_.BytesTransferred}},
  @{Name="PerMoveTransferRate"; Expression={((ToKB $_.BytesTransferred) / $_.TotalInProgressDuration.TotalSeconds) * 3600 / 1024}}

$perMoveInfo = $perMoveInfo| sort permovetransferrate -desc
$perMoveInfo = @($perMoveInfo);
$perMoveInfo | Export-Csv "$($name).csv"  -NoTypeInformation -Encoding UTF8

$perMoveInfo = $perMoveInfo| select -first ($perMoveinfo.count * ($percentile/100))
$totalInProgressDurationInTicks = ($perMoveInfo  | measure -property TotalInProgressDurationInTicks -Sum).Sum
$TotalStalledDueToCIInTicks = ($perMoveInfo  | measure -property TotalStalledDueToCIInTicks -Sum).Sum
$TotalStalledDueToHAInTicks = ($perMoveInfo  | measure -property TotalStalledDueToHAInTicks -Sum).Sum

$MeasuredOverallDurationInTicks = ($perMoveInfo | select @{Name="OverallDurationInTicks"; Expression={$_.OverallDuration.Ticks}} | measure -property OverallDurationInTicks -Sum -Maximum -Minimum -Average)
$MeasuredIdleDurationInTicks = ($perMoveInfo | select @{Name="TotalIdleDurationInTicks"; Expression={$_.TotalIdleDuration.Ticks}} | measure -property TotalIdleDurationInTicks -Sum -Maximum -Minimum -Average)
$MeasuredSourceProviderDurationInTicks = ($perMoveInfo | select @{Name="SourceProviderDurationInTicks"; Expression={$_.SourceProviderDuration.Ticks}} | measure -property SourceProviderDurationInTicks -Sum -Maximum -Minimum -Average)
$MeasuredDestinationProviderDurationInTicks = ($perMoveInfo | select @{Name="DestinationProviderDurationInTicks"; Expression={$_.DestinationProviderDuration.Ticks}} | measure -property DestinationProviderDurationInTicks -Sum -Maximum -Minimum -Average)
$MeasuredRelinquishedDurationInTicks = ($perMoveInfo |  measure -property RelinquishedDurationInTicks -Sum -Maximum -Minimum -Average)

$TotalOverallDurationInTicks = $MeasuredOverallDurationInTicks.Sum
$TotalIdleDurationInTicks = $MeasuredIdleDurationInTicks.Sum
$TotalSourceProviderDurationInTicks = $MeasuredSourceProviderDurationInTicks.Sum
$TotalDestinationProviderDurationInTicks = $MeasuredDestinationProviderDurationInTicks.Sum

$IdlePercent = $("{0:p2}" -f ((Nullify $TotalIdleDurationInTicks) / $TotalInProgressDurationInTicks))
$SourcePercent = $("{0:p2}" -f ((Nullify $TotalSourceProviderDurationInTicks) / $TotalInProgressDurationInTicks))
$DestinationPercent = $("{0:p2}" -f ((Nullify $TotalDestinationProviderDurationInTicks) / $TotalInProgressDurationInTicks))

$TotalStalledDueToTargetCpuInTicks = ($perMoveInfo  | measure -property TotalStalledDueToTargetCpuInTicks -Sum).Sum
$TotalStalledDueToSourceCpuInTicks = ($perMoveInfo  | measure -property TotalStalledDueToSourceCpuInTicks -Sum).Sum
$TotalStalledDueToMailboxLockedDurationInTicks = ($perMoveInfo  | measure -property TotalStalledDueToMailboxLockedDurationInTicks -Sum).Sum
$TotalStalledDueToSourceProxyUnknownInTicks = ($perMoveInfo  | measure -property TotalStalledDueToSourceProxyUnknownInTicks -Sum).Sum
$TotalStalledDueToTargetProxyUnknownInTicks = ($perMoveInfo  | measure -property TotalStalledDueToTargetProxyUnknownInTicks -Sum).Sum

$WordBreaking_TotalTimeProcessingMessagesInTicks = ($perMoveInfo  | measure -property WordBreaking_TotalTimeProcessingMessagesInTicks -Sum).Sum

$CIStallPercent = $($TotalStalledDueToCIInTicks/$totalInProgressDurationInTicks)
$HAStallPercent = $($TotalStalledDueToHAInTicks/$totalInProgressDurationInTicks)
$SourceCPUStallPercent = $($TotalStalledDueToSourceCpuInTicks/$totalInProgressDurationInTicks)
$TargetCPUStallPercent = $($TotalStalledDueToTargetCpuInTicks/$totalInProgressDurationInTicks)
$MailboxLockedStallPercent = $($TotalStalledDueToMailboxLockedDurationInTicks/$totalInProgressDurationInTicks)
$ProxyUnknownStallPercent = $(($TotalStalledDueToSourceProxyUnknownInTicks + $TotalStalledDueToTargetProxyUnknownInTicks)/$totalInProgressDurationInTicks)

$totalStalledTimeInTicks = $TotalStalledDueToCIInTicks + $TotalStalledDueToHAInTicks + $TotalStalledDueToSourceCpuInTicks + $TotalStalledDueToTargetCpuInTicks +  $TotalStalledDueToMailboxLockedDurationInTicks + $TotalStalledDueToTargetProxyUnknownInTicks + $TotalStalledDueToSourceProxyUnknownInTicks
$TotalTransientFailureDurationInTicks = ($perMoveInfo  | measure -property TotalTransientFailureDurationInTicks -Sum).Sum
$TransientFailurePercent = $($TotalTransientFailureDurationInTicks/$totalInProgressDurationInTicks)
$delayRatio = $($totalStalledTimeInTicks/$totalInProgressDurationInTicks)
$totalMailboxSizeInMB = ($perMoveInfo  | measure -property MailboxSizeInMB -Sum).Sum
$totalTransferredMailboxSizeInMB = ($perMoveInfo  | measure -property TransferredMailboxSizeInMB -Sum).Sum
$MeasuredPerMoveTransferRate = ($perMoveInfo  | measure -property PerMoveTransferRate -Average -Maximum -Minimum) 
$totalMegabytesTransferred = ($perMoveInfo  | measure -property BytesTransferredInMB -Sum).Sum 
$perMoveRateInMBPerHour = ($perMoveInfo | measure -Property PerMoveRate -average).Average

$averageSourceLatency = ($perMoveInfo | ? {$_.SourceLatencySampleCount -gt 0} | measure -Property AverageSourceLatency -average).Average
$averageNumberOfSourceSideRemoteCalls = ($perMoveInfo | measure -Property TotalNumberOfSourceSideRemoteCalls -average).Average
$averageDestinationLatency = ($perMoveInfo | ? {$_.DestinationLatencySampleCount -gt 0} | measure -Property AverageDestinationLatency -average).Average
$averageNumberOfDestinationSideRemoteCalls = ($perMoveInfo | measure -Property TotalNumberOfDestinationSideRemoteCalls -average).Average
$WordBreakingVsInProgressRatio  = $("{0:p2}" -f $($WordBreaking_TotalTimeProcessingMessagesInTicks/$totalInProgressDurationInTicks))

$mailboxCount = $batch.Count

$nl = [System.Environment]::NewLine

$failures = ""

$stats | % {  if($_.Report.Failures -ne $null) { $failures += $_.Alias + ": " + $_.Report.Failures + $nl}}

if($failures.Length -gt 0){$failures | Add-Content -Path "$($name)failures.txt" -Encoding ASCII ;   write-warning "Move reports contains failures. Check $($name)failures.txt"}

return New-Rec -name $name -mailboxCount $stats.Count -moveDuration $(GetTimeSpan($MoveDurationInTicks)) -startTime $($startTime.QueuedTimeStamp) -completionTime $lastTimestamp `
   -TotalMailboxSizeInGB $(RoundIt($($totalMailboxSizeInMB / 1024))) -TotalTransferredMailboxSizeInGB $(RoundIt($($totalTransferredMailboxSizeInMB / 1024))) `
   -TotalThroughputGBPerHour $(RoundIt($($totalTransferredMailboxSizeInMB / $MoveDuration.TotalHours / 1024))) -PerMoveThroughputGBPerHour $(RoundIt($perMoveRateInMBPerHour / 1024)) `
   -StalledVsInProgressRatio $("{0:p2}" -f $delayRatio) -WordBreakingVsInProgressRatio $WordBreakingVsInProgressRatio  `
   -CIStallVsInProgressRatio $("{0:p2}" -f $CIStallPercent) -HAStallVsInProgressRatio $("{0:p2}" -f $HAStallPercent) `
   -TargetCPUStallVsInProgressRatio $("{0:p2}" -f $TargetCPUStallPercent ) -SourceCPUStallVsInProgressRatio $("{0:p2}" -f $SourceCPUStallPercent ) `
   -MailboxLockedStallVsInProgressRatio $("{0:p2}" -f $MailboxLockedStallPercent ) -ProxyUnknownStallVsInProgressRatio $("{0:p2}" -f $ProxyUnknownStallPercent  ) `
   -TransientFailurePercent $("{0:p2}" -f $TransientFailurePercent) `
   -IdlePercent $IdlePercent -SourcePercent $SourcePercent -DestinationPercent $DestinationPercent `
   -MeasuredOverallDuration $MeasuredOverallDurationInTicks -MeasuredIdleDuration $MeasuredIdleDurationInTicks -MeasuredSourceProviderDuration $MeasuredSourceProviderDurationInTicks -MeasuredDestinationProviderDuration $MeasuredDestinationProviderDurationInTicks `
   -MeasuredRelinquishedDuration $MeasuredRelinquishedDurationInTicks `
   -TotalGBTransferred $(RoundIt($($totalMegabytesTransferred/1024))) -MeasuredPerMoveTransferRate $MeasuredPerMoveTransferRate `
   -AverageSourceLatency $(RoundIt($($averageSourceLatency))) -AverageNumberOfSourceSideRemoteCalls $(RoundIt($($averageNumberOfSourceSideRemoteCalls))) `
   -AverageDestinationLatency $(RoundIt($($averageDestinationLatency))) -AverageNumberOfDestinationSideRemoteCalls $(RoundIt($($averageNumberOfDestinationSideRemoteCalls))) `
}

function New-Rec()
{
param ([string]$name, [int]$MailboxCount, $MoveDuration, $StartTime, $CompletionTime, 
$TotalMailboxSizeInGB, $TotalTransferredMailboxSizeInGB, $TotalThroughputGBPerHour,$PerMoveThroughputGBPerHour,
$StalledVsInProgressRatio,$WordBreakingVsInProgressRatio,
$CIStallVsInProgressRatio, $HAStallVsInProgressRatio,$TargetCPUStallVsInProgressRatio,$SourceCPUStallVsInProgressRatio,$MailboxLockedStallVsInProgressRatio, $ProxyUnknownStallVsInProgressRatio,
$TransientFailurePercent, $IdlePercent, $SourcePercent, $DestinationPercent, $MeasuredOverallDuration, $MeasuredIdleDuration, $MeasuredSourceProviderDuration, $MeasuredDestinationProviderDuration, $MeasuredRelinquishedDuration, $TotalGBTransferred, $MeasuredPerMoveTransferRate,
$AverageSourceLatency, $AverageNumberOfSourceSideRemoteCalls, $AverageDestinationLatency, $AverageNumberOfDestinationSideRemoteCalls)

 $rec = new-object PSObject

  $rec | add-member -type NoteProperty -Name Name -Value $Name
  $rec | add-member -type NoteProperty -Name StartTime -Value $StartTime 
  $rec | add-member -type NoteProperty -Name EndTime -Value $CompletionTime
  $rec | add-member -type NoteProperty -Name MigrationDuration -Value $MoveDuration

  $rec | add-member -type NoteProperty -Name MailboxCount -Value $MailboxCount
  $rec | add-member -type NoteProperty -Name TotalGBTransferred -Value $TotalGBTransferred
  $rec | add-member -type NoteProperty -Name PercentComplete -Value $(RoundIt($TotalTransferredMailboxSizeInGB / $TotalMailboxSizeInGB * 100))
  
  $rec | add-member -type NoteProperty -Name MaxPerMoveTransferRateGBPerHour -Value $(RoundIt($MeasuredPerMoveTransferRate.Maximum / 1024))
  $rec | add-member -type NoteProperty -Name MinPerMoveTransferRateGBPerHour -Value $(RoundIt($MeasuredPerMoveTransferRate.Minimum / 1024))
  $rec | Add-Member -Type NoteProperty -Name AvgPerMoveTransferRateGBPerHour -Value $(RoundIt($MeasuredPerMoveTransferRate.Average / 1024))

  #transfer size is greater than the source mailbox size due to transient failures and other factors. This shows how close these numbers are.
  $rec | add-member -type NoteProperty -Name MoveEfficiencyPercent -Value $(RoundIt($TotalTransferredMailboxSizeInGB / $TotalGBTransferred * 100))
  
  $rec | add-member -type NoteProperty -Name AverageSourceLatency -Value $AverageSourceLatency #applies to onboarding
  $rec | add-member -type NoteProperty -Name AverageDestinationLatency -Value $AverageDestinationLatency #applies to offboarding
  
  $rec | add-member -type NoteProperty -Name IdleDuration -Value $IdlePercent

  $rec | add-member -type NoteProperty -Name SourceSideDuration -Value $SourcePercent
  $rec | add-member -type NoteProperty -Name DestinationSideDuration -Value $DestinationPercent

  $rec | add-member -type NoteProperty -Name WordBreakingDuration -Value $WordBreakingVsInProgressRatio
  $rec | add-member -type NoteProperty -Name TransientFailureDurations -Value $TransientFailurePercent

  $rec | add-member -type NoteProperty -Name OverallStallDurations -Value $StalledVsInProgressRatio
  $rec | add-member -type NoteProperty -Name ContentIndexingStalls -Value $CIStallVsInProgressRatio
  $rec | add-member -type NoteProperty -Name HighAvailabilityStalls -Value $HAStallVsInProgressRatio
  $rec | add-member -type NoteProperty -Name TargetCPUStalls -Value $TargetCPUStallVsInProgressRatio
  $rec | add-member -type NoteProperty -Name SourceCPUStalls -Value $SourceCPUStallVsInProgressRatio
  $rec | add-member -type NoteProperty -Name MailboxLockedStall -Value $MailboxLockedStallVsInProgressRatio
  $rec | add-member -type NoteProperty -Name ProxyUnknownStall -Value $ProxyUnknownStallVsInProgressRatio
  
  return $rec
}

#utility functions

function LogIt($str)
{
   $currentTime = Get-Date -Format "hh:mm:ss"
   $loggedText = "[{0}] {1}" -f $currentTime,$str
   write-host $loggedText
}

function GetTimeSpan($ticks)
{
  if($seconds -eq 0)
  {
    return "0"
  }
  $a = [TimeSpan]::FromTicks($ticks)
  if($a.Days -eq 0)
  {
    return "{0:00}:{1:00}:{2:00}" -f $a.hours,$a.minutes,$a.seconds
  }
  else
  {
    return "{0} day(s) {1:00}:{2:00}:{3:00}" -f $a.days,$a.hours,$a.minutes,$a.seconds
  }
}

function RoundIt($num)
{
  return "{0:N2}" -f $num
}


 function Nullify($var)
 {
   if($var -eq $null)
   {
	 return 0
   }
   else
   {
     return $var
   }
 }

function ByteStrToBytes($str)
{
   if($str -eq $null)
   {
     return 0;
   }

   $str = $str.ToString()
   return [int64]$str.substring($str.IndexOf('(') + 1, $str.IndexOf(' bytes)')-$str.IndexOf('(')-1)
}

function ToMB($str)
{
	return (ByteStrToBytes $str)/1024/1024
}

function ToKB($str)
{
	return (ByteStrToBytes $str)/1024
}

function GetArchiveSize($size, $flags)
{
	if($flags.ToString().Contains("MoveOnlyArchiveMailbox"))
    {
        return $null
    }
    
    return $size;
}


function LogWrite
{
   Param ([string]$logstring)
   $Data = "$(Get-Date -f "yyyy-MM-dd HH:mm:ss"): "
   $logstring = $Data + $logstring
   Add-content $Logfile -value $logstring
}

Function AuthentificationEXO {

    $TenantId = "<VotreTenantId>"
    $AppId = "<VotreAppId>"
    $Cert = Get-PfxCertificate -FilePath "<CheminVersVotreCertificat>"
    Connect-ExchangeOnline -Certificate $Cert -AppId $AppId -Organization "<VotreDomaine>" -ShowBanner:$false

}

AuthentificationEXO



foreach($batch in $Batches)
{
    $sw                      = [Diagnostics.Stopwatch]::StartNew()
    $batch
   #moves = Get-MoveRequest  -ResultSize unlimited | ?{($_.Status -notlike "Completed*") -and ($_.BatchName -like "*$($batch)")}
    $moves = Get-MoveRequest  -ResultSize unlimited | ?{($_.Status -notlike "Completed*") -and ($_.BatchName -like "*$($batch)")}
    Write-Host "$batch --------------------------------------------" -ForegroundColor Green
    $mybatch = $($batch).Split(":")[1]

    #Count move requests
    $tot =$moves.Count
    $tot

    # Move request array
    $moveArray        = [System.Collections.ArrayList]::new()
    # Error array
    $errorArray        = [System.Collections.ArrayList]::new()


    $i=0

    # get move request statistics
    foreach($move in $moves)
    {
         ++$i
        try
        {
           $stat = $move | Get-MoveRequestStatistics �IncludeReport -ErrorVariable MyERR -ErrorAction Silentlycontinue       
           $moveArray.Add($stat) | Out-Null
           $MyERR     
           write-host "$i/$tot - $($move.DisplayName) - $($move.BatchName)  - $($move.Identity) - $($move.Status)" -ForegroundColor Green
           LogWrite "[INFO]  $i/$tot - Req stat for $($move.DisplayName) is getted - $($move.Status)" 
        }
        catch
        {
           $txt = "[ERROR] $i/$tot - Req stat for $($move.DisplayName) is getted - $($move.Status)" ; LogWrite $txt 
           write-host "$txt" -ForegroundColor DarkYellow
           $errorArray.Add($txt)
           $MyERR
        }

    }


    #File Name
    $fileName ="$($mybatch)_$(Get-date -f MMdd-hhmmss)"

    $resp = ProcessStats -stats $moveArray  -name $fileName 

    $filepath = "D:\Scripts\#BatchReport\AnalyzeMoveRequestStats\$($fileName).csv" 
    $compressedpath = "D:\Scripts\#BatchReport\AnalyzeMoveRequestStats\$($fileName).zip"

    #Create zip
    Get-ChildItem -Path "D:\Scripts\#BatchReport\AnalyzeMoveRequestStats\" -Recurse -File -include *.csv,*.txt | Compress-Archive -DestinationPath $compressedpath

    $Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

    $html =@"
<!DOCTYPE html>
<html>
<head>
<title>Repport</title>
<style>
table {font-family: arial, sans-serif;border-collapse: collapse;width: 100%;}
td, th {border: 1px solid #dddddd;text-align: left;padding: 8px;}
tr:nth-child(even) {background-color: #dddddd;}
</style>
</head>
<body>
</table>
<p></p>
<h3 >Batch analysis report - $($batchName)</h3>
<p></p>
<table>
<tr><td>StartTime</td><td>$($resp.StartTime)</td><td>Timestamp of the first injected request</td></tr>
<tr><td>EndTime</td><td>$($resp.EndTime)</td><td>Timestamp of the last completed request. If there isn't a completed/autosuspended move, this is set to the current time.</td></tr>
<tr><td>MigrationDuration</td><td>$($resp.MigrationDuration)</td><td>EndTime - StartTime</td></tr>
<tr><td>MailboxCount</td><td>$($resp.MailboxCount)</td><td># of mailboxes</td></tr>
<tr><td>TotalGBTransferred</td><td>$($resp.TotalGBTransferred)</td><td>Total amount of data transferred</td></tr>
<tr><td>PercentComplete</td><td>$($resp.PercentComplete)</td><td>Completion percentage</td></tr>
<tr><td>MaxPerMoveTransferRateGBPerHour</td><td>$($resp.MaxPerMoveTransferRateGBPerHour)</td><td>Maximum per-mailbox transfer rate</td></tr>
<tr><td>MinPerMoveTransferRateGBPerHour</td><td>$($resp.MinPerMoveTransferRateGBPerHour)</td><td>Minimum per-mailbox transfer rate</td></tr>
<tr><td>AvgPerMoveTransferRateGBPerHour</td><td>$($resp.AvgPerMoveTransferRateGBPerHour)</td><td style ="border-color: coral; color:red">Average per-mailbox transfer rate. For onboarding to Office 365, any value greater than 0.5 GB/h represents a healthy move rate. The normal range is 0.3 - 1 GB/h.</td></tr>
<tr><td>MoveEfficiencyPercent</td><td>$($resp.MoveEfficiencyPercent)</td><td style ="border-color: coral; color:red">Transfer size is always greater than the source mailbox size due to transient failures and other factors. This percentage shows how close these numbers are and is calculated as SourceMailboxSize/TotalBytesTransferred. A healthy range is 75-100%.</td></tr>
<tr><td>AverageSourceLatency</td><td>$($resp.AverageSourceLatency)</td><td>This is the duration calculated by making no-op WCF web service calls to the source MRSProxy service. It's not the same as network ping and 100ms is desirable for better throughput.</td></tr>
<tr><td>AverageDestinationLatency</td><td>$($resp.AverageDestinationLatency)</td><td>Similar to AverageSourceLatency, but applies to off-boarding from Office 365. This value isn't applicable in this example scenario.</td></tr>
<tr><td>IdleDuration</td><td>$($resp.IdleDuration)</td><td>Amount of time that the MRSProxy service request waits in the MRSProxy service's in-memory queue due to limited resource availability.</td></tr>
<tr><td>SourceSideDuration</td><td>$($resp.SourceSideDuration)</td><td style ="border-color: coral; color:red">Amount of time spent in the source side which is the on-premises MRSProxy service for onboarding and Office 365 MRSProxy service for off-boarding. The typical range for this value is 60-80% for onboarding. A higher average latency and transient failure rate will increase this rate. A healthy range is 60-80%.</td></tr>
<tr><td>DestinationSideDuration</td><td>$($resp.DestinationSideDuration)</td><td style ="border-color: coral; color:red">Amount of time spent in the destination side which is Office 365 MRSProxy service for onboarding and on-premises MRSProxy service for off-boarding. The typical range for this value is 20-40% for onboarding. Target stalls such as CPU, ContentIndexing, and HighAvailability will increase this rate. A healthy range is 20-40%.</td></tr>
<tr><td>WordBreakingDuration</td><td>$($resp.WordBreakingDuration)</td><td>Amount of time spent in separating words for content indexing. A healthy range is 0-15%.</td></tr>
<tr><td>TransientFailureDurations</td><td>$($resp.TransientFailureDurations)</td><td>Amount of time spent in transient failures, such as intermittent connectivity issues between MRS and the MRSProxy services. A healthy range is 0-5%.</td></tr>
<tr><td>OverallStallDurations</td><td>$($resp.OverallStallDurations)</td><td>Amount of time spent while waiting for the system resources to be available such as CPU, CA (ContentIndexing), HA (HighAvailability). A healthy range is 0-15%.</td></tr>
<tr><td>ContentIndexingStalls</td><td>$($resp.ContentIndexingStalls)</td><td>Amount of time spent while waiting for Content Indexing to catch up.</td></tr>
<tr><td>HighAvailabilityStalls</td><td>$($resp.HighAvailabilityStalls)</td><td>Amount of time spent while waiting for High Availability (replication of the data to passive databases) to catch up.</td></tr>
<tr><td>TargetCPUStalls</td><td>$($resp.TargetCPUStalls)</td><td>Amount of time spent while waiting for availability of the CPU resource on the destination side.</td></tr>
<tr><td>SourceCPUStalls</td><td>$($resp.SourceCPUStalls)</td><td>Amount of time spent while waiting for availability of the CPU resource on the source side.</td></tr>
<tr><td>MailboxLockedStall</td><td>$($resp.MailboxLockedStall)</td><td>Amount of time spent while waiting for mailboxes to be unlocked. In some cases, such as connectivity issues, the source mailbox can be locked for some time.</td></tr>
<tr><td>ProxyUnknownStall</td><td>$($resp.ProxyUnknownStall)</td><td>Amount of time spent while waiting for availability of remote on-prem resources such as CPU. The resource can be identified by looking at the generated failures log file.</td></tr>
</table>
<p></p>
</body>
</html>
"@


    if($moves.Count -gt 0)
     {
        #Mail ----------------------------------------------------------------------------------
      
        $subject  = "AnalyzeMoveRequestStats $($moves.Count) - $(Get-Date -Format "dd-MM-yyyy HH:mm")"
        #[String]$html = $resp | ConvertTo-Html  -Head $Header  

        foreach($emailRecipient in $recipientEmails)
        {
            Send-MailMessage -SmtpServer $smtpServer  -Subject $subject -From $from -To $emailRecipient -Body  $html -Attachments $compressedpath -BodyAsHtml   -Priority High -Encoding utf8 
            LogWrite -logstring "Email report was sent to  : $($emailRecipient)"
            sleep -Seconds 4
        }
}


    $("$($sw.Elapsed.Minutes):$($sw.Elapsed.Minutes)")

    $sw.Stop()

}

