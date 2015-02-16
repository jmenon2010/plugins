'===============================================================================
' Name    : check_volfree.vbs
' Usage   : cscript.exe //NoLogo //T:10 check_volfree.vbs -n volume -w <warn> -c <crit> | -h
' Author  : Jayan Menon, Komodo Cloud LLC (www.komodocloud.com)
' Version : 2015.02.15

' Description: Calculates space utilization of a Windows disk that does 
'              not have a drive letter assigned, using the volume label.
' License:
' - This script is supplied as-is without any support.
' - You free to modify/distribute this script as you wish, but you must have the
'   following line in the script:
'   Original author Jayan Menon, Komodo Cloud LLC (www.komodocloud.com)
'
'===============================================================================
Option Explicit

' Script version Constant
Const VERSION = "2015.02.15"

' Nagios states Constants
Const STATE_OK          = 0
Const STATE_WARNING     = 1
Const STATE_CRITICAL    = 2
Const STATE_UNKNOWN     = 3

' Global variables
Dim wThreshold  : wThreshold  = 0
Dim cThreshold  : cThreshold  = 0
Dim strLabel	: strLabel   = ""
Dim strComputer	: strComputer = "."
Dim strStatus1	: strStatus1  = ""
Dim strStatus2	: strStatus2  = ""
Dim objWMIService, colItems, objItem
Dim intCap, intFree, intUsed, pctUsed, intWarn, intCrit 

Wscript.Quit(Main())

Function Main() : Main = STATE_UNKNOWN
    Dim strArg, strNextArg, intFileCount
    ' Set default values for variables
    strArg = ""
    strNextArg = ""

    ' If no arguments were specified, then print usage and exit
    If (Wscript.Arguments.Count = 0) Then
        PrintUsage()
        Exit Function
    End If

    For Each strArg in Wscript.Arguments
        If (strNextArg = "") Then
            Select case LCase(strArg)
                case "-h", "--help"
                    Call Help()
                    Exit Function
                case "-l", "--label"
                    strNextArg = "label"
                case "-w", "--warn"
                    strNextArg = "warning"
                case "-c", "--crit"
                    strNextArg = "critical"
                case else
                    ' Ignore all unknown arguments
                    WScript.Echo "Unknown argument '" & strArg & "', ignoring."
            End Select
        Else
            Select case strNextArg
                case "label"
                    strNextArg = ""
					strLabel = strArg
				case "warning"
                    strNextArg = ""                
                    If (IsNumeric(strArg)) Then wThreshold = CInt(strArg)
                case "critical"
                    strNextArg = ""                
                    If (IsNumeric(strArg)) Then cThreshold = CInt(strArg)
            End Select
        End If
    Next
    If (strLabel = "") Or (wThreshold = 0) Or (cThreshold = 0) Then
        WScript.Echo "Missing or invalid arguments, check usage."
        Exit Function
    End If
	
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
	Set colItems = objWMIService.ExecQuery("Select * from Win32_Volume where Label ='" & strLabel & "'")
	For Each objItem In colItems
		intCap  = Round(objItem.Capacity / 1073741824,2) 
		intFree = Round(objItem.FreeSpace / 1073741824,2)
		intUsed = Round(intCap - intFree, 2)
		pctUsed = Round(intUsed / intCap * 100, 2)
		intWarn = Round(intCap * wThreshold / 100)
		intCrit = Round(intCap * cThreshold / 100)
		if pctUsed > cThreshold Then
			Main = STATE_CRITICAL
		ElseIf pctUsed > wThreshold Then
			Main = STATE_WARNING
		Else
			Main = STATE_OK
		End If
		strStatus1 = objItem.Label & " - Total/Used/Free " & intCap & "/" & intUsed & "/" & intFree
		strStatus2 = "'" & objItem.Label & " Used'=" & intUsed & ";" & intWarn & ";" & intCrit & ";0.00;" & intCap 
		WScript.Echo strStatus1 & " | " & strStatus2
	Next
End Function

Sub Usage()
    Wscript.Echo "Usage: " & Wscript.ScriptName & " -l label -w <warn> -c <crit> | -h"
End Sub

Sub Help()
    WScript.Echo "Check_Files - Nagios NRPE plugin for windows, ver. " & VERSION
    WScript.Echo "Copyright (C) 2015, Jayan Menon <jmoolayil@gmail.com>"
    WScript.Echo ""
    Call Usage()
    WScript.Echo ""
    
    WScript.Echo "Command-line options:"
    WScript.Echo "   -l, --label <label>  : Disk volume label"
    WScript.Echo "   -w, --warn <warn>    : set WARNING state"
    WScript.Echo "   -c, --crit <crit>    : set CRITICAL state"
    WScript.Echo "   -h, --help           : print this help message"
    WScript.Echo ""

    WScript.Echo "Example:"
    WScript.Echo "   "  & Wscript.ScriptName & " -l SQLDATA -w 75 -c 85"
    WScript.Echo ""
    WScript.Echo "   Check the utilization of the volume named SQLDATA "
	  Wscript.Echo "   return WARNING if utilization is over 75% "
	  Wscript.Echo "   return CRITICAL if above 85%"
	  
End Sub
