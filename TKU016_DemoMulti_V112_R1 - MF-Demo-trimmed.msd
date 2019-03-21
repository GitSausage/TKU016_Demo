'
'  TKU016 Demo Program
'
'  V1.00    2017/04/05    Based off of Demo V1.12R1
'                         High-sensititivty 
'                         1 - touch - only 
'                         button sound#4 
'                         no brightness change
'
'  V1.01    2019/03/22    Idle Mode

'initializations
mpx = 0
SwMaxNum = &hff
SwMaxCnt = 0
LedAct = 0
LedBr = 15
ad = 0
d = 0
d2 = 0

'----- Main -----------------------------------------------
Sub Start()
	EventTimerSet enable, 1	'Event Timer Condition
	EventEnable

	'MSW settings
	Print &h1f,&h4b,&hf0,&h00	'Txd Disable

	'--- Common Parameter ---
	Print &h1F, &h4B, &h54, &hff
	Print 4		'THR		62.5%
	Print &hff	'OFFS
	Print 20		'HYS
	Print 3		'SON
	Print 3		'SOFF
	Print 10		'CAL
	Print &hff	'THR_L
	Print &hff	'THR_H
		
	'--- Common Parameter2 ---
	Print &h1F, &h4B, &h54, &hfe
	Print 25		'SW ON Limit Time
	Print &hff	'RSV
	Print &hff	'RSV
	Print &hff	'RSV
	Print &hff	'RSV
	Print &hff	'RSV
	Print &hff	'RSV
	Print &hff	'RSV
		
	Print &h1f,&h4b,&hf0,&h01	' Txd Enable

	'----- Max REF Set -------------------------
	ad = SW_THR_L

	ad2 = &H300
	For mpx = 0 To 15	
		d =  Peek( ad)
		d2 =  Peek( ad + 1)
		d = d + d2 * 256    ' the count value is 2 bytes of data, the 2nd byte has to be shifted by 256
		TpIN = &h1200 + mpx		' Default reference value
		d2 = TpIN
		d = d + d2    ' 2 byte value:  default reference value + offset threshold
		
		VPoke ad2,d Mod 256    ' Store adjusted 2 byte reference value from &h300
		VPoke ad2 + 1,d / 256
		
		ad = ad + 2    ' shift to next byte
		ad2 = ad2 + 2
	Next mpx
	'--------------------------------------------
	
    Loop1:
        DEMO_TOUCH
        GoTo Loop1        
        
End Sub

Sub DEMO_TOUCH()
	SwMaxNum = &hff
	SwMaxTemp = 0
	SwMaxCnt = 0

	For mpx = 0 To 15
		VPoke  &h100 + mpx , 0
	Next mpx
	
    DEMO_TOUCH_L1:
        VPoke &h200, 0		'Touch Flag

        '----- REF Over Check -------
        VPoke &h201, 0		'REF Over
        ad = &h300
        For mpx = 0 To 15
            d = VPeek( ad)
            d2 = VPeek( ad + 1)
            d = d + d2 * 256    ' retrieve the threshold value adjusted from the reference value
            ad = ad + 2    ' shift to next byte
            
            TpIN = &h1200 + mpx		' read in reference value
            d2 = TpIN
        
            If d2 > d Then    ' if the reference value is greater than the threshold value
                VPoke &h201, 1		'REF Over >> detected touch.  comparing &h1200 to previously stored &h300
            End If
        Next mpx
        '---------------------------
        
        Print &h1f,&h4b,&hf0,&h00	' Txd Disable
        '--- SW Level Order ---
        Print &h1f,&h4b,&h12    ' this command alone could be used to read back the touch inputs, but we decide to take samples below.
        Print &h1f,&h4b,&hf0,&h01	' Txd Enable
                
        '----- Test -------
        d = VPeek( 1)		'Max Touch Level. 2nd byte of read buffer (work memory)
        d2 = VPeek( &h201)		'REF Over
        If d2 = 0 Then    ' on first pass, this is bypassed. Line 132 !(d2 > d) & Line 141 touch is read. The statements below take samples
            If d <> &hff Then
                '--- Same SW Check ----
                If d = SwMaxTemp Then
                    '--- Continuos Check ----
                    If SwMaxCnt < 5 Then
                        SwMaxCnt = SwMaxCnt + 1
                        If SwMaxCnt = 5 Then
                            VPoke &h200, 1		'Touch Flag
                            SwMaxNum = SwMaxTemp
                        End If
                    End If
                Else
                    '--- Other SW ---
                    SwMaxTemp = d
                    SwMaxCnt = 0
                End If
            Else
                '--- SW OFF ---
                SwMaxNum = &hff
                SwMaxCnt = 0
            End If
        Else
            '--- SW OFF ---
            SwMaxNum = &hff
            SwMaxCnt = 0
        End If

        '----- Touch ---------------------
        d = VPeek( &h200)		'Touch Flag
        If d = 1 Then
            BUZ_ON
        End If
        
        '----- Led Control ------------------
        For mpx = 0 To 15		
            If mpx = SwMaxNum Then
                Print &H1f,&h4B,&h21,mpx,&h00
            Else
                Print &H1f,&h4B,&h21,mpx,LedBr * 16
            End If
        Next mpx
        
        Sleep 1
        GoTo DEMO_TOUCH_L1

    DEMO_TOUCH_LE:
    	'/* Wait */
    	Sleep 35

End Sub
	
'-------------------------------------------------------
'Timer Event Process
Sub Timer_Event()
	If RecCount <> 0 Then
		End
	End If
End Sub

'----- Wait Loop ---------------------
Sub Wait ()
	brk = 0
	Wait_Lp:
    	GoTo Wait_Lp
	Wait_LpE:
End Sub

'----- SW THR LOW ------------------- 
SW_THR_L:
    Data 328 Mod 256 , 328 / 256
    Data 556 Mod 256 , 556 / 256
    Data 535 Mod 256 , 535 / 256
    Data 554 Mod 256 , 554 / 256
    Data 328 Mod 256 , 328 / 256
    Data 572 Mod 256 , 572 / 256
    Data 523 Mod 256 , 523 / 256
    Data 568 Mod 256 , 568 / 256
    Data 609 Mod 256 , 609 / 256
    Data 562 Mod 256 , 562 / 256
    Data 530 Mod 256 , 530 / 256
    Data 584 Mod 256 , 584 / 256
    Data 589 Mod 256 , 589 / 256
    Data 581 Mod 256 , 581 / 256
    Data 558 Mod 256 , 558 / 256
    Data 572 Mod 256 , 572 / 256

'----- Buzzer Table ------------------------
BUZ_TABLE:
	'-4-
	Data	1,0
	Data 	&h58,1
	Data 0,0
	Data 0,0

'----- Buzzer ON Command ------------------------------
Sub BUZ_ON()
	size = 0
	mpx = BUZ_TABLE
	size =  Peek( mpx)
	mpx = mpx + 2
	Print &h1f,&h4b,&h31,size

    BUZ_ON_L1:
    	If size = 0 Then
		    GoTo BUZ_ON_LE
	    End If
    	
        '--- Data Read and Command Set ---
    	d =  Peek( mpx)
    	Print d
    	mpx = mpx + 1
    	d =  Peek( mpx)
    	Print d
    	mpx = mpx + 1
    	size = size - 1
		
	    GoTo BUZ_ON_L1

    BUZ_ON_LE:

End Sub
