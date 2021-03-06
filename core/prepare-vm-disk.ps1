#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
Write-Output "------------------------------------------"
Write-Output "Custom script: prepare-vm-disk.ps1"
Write-Output "------------------------------------------"
$disks = Get-Disk -ErrorAction Ignore | Sort Number
# 83..89 = S..Y 
$letters = 83..89 | ForEach-Object { [char]$_ } 
$count = 0
$label = "datadisk"

Write-Output "Drives found: $($disks.Count)"
for($index = 2; $index -lt $disks.Count; $index++) {
    $driveLetter = $letters[$count].ToString()
    if ($disks[$index].partitionstyle -eq 'raw') {
        Write-Output "Drive Letter formatting: $($driveLetter)"
        $disks[$index] | Initialize-Disk -PartitionStyle MBR -PassThru | 
            New-Partition -UseMaximumSize -DriveLetter $driveLetter | 
            Format-Volume -FileSystem NTFS -NewFileSystemLabel "$label.$count" -Confirm:$false -Force
        Write-Output "Drive Letter mapped: $($driveLetter)"
    } else {
        $disks[$index] | Get-Partition | Set-Partition -NewDriveLetter $driveLetter -ea Ignore
        Write-Output "Drive Letter mapped: $($driveLetter)"
    }
    $count++
}
Write-Output "------------------------------------------"
Write-Output "done"
Write-Output "------------------------------------------"
$True
