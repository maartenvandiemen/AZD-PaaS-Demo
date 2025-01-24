#!/usr/bin/env pwsh

if ($PSVersionTable.OS -notmatch 'Windows') {
    throw "This demo can only be run on Windows."
}