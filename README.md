# ccs-maintenance
PowerShell script that automates the Cajun Cloud Services maintenance process

## Accomplishes the following maintenance tasks:
* Flush DNS cache
* Run Malwarebytes therat scan
* Run disk defrag/optimize on all the drives
* Delete temp files and caches
  * Windows temp files
  * Prefetch files
  * User temp files
  * Internet cache
  * Delivery Optimization cache
* Disk cleanup
* Empty recycle bin
* Run DISM RestoreHealth
* Run System File Checker /scannow
