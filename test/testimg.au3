#include <GdiPlus.au3>
;#include <myOcrFunc.au3>

_GDIPlus_Startup ()

$s_dir = "D:\��Ŀ\Longzhu\live2\cv"
$hBitmap1 = _GDIPlus_BitmapCreateFromFile($s_dir & "\t.png")
$array1 = _myReadBitmapMsg($hBitmap1, 1)

$hBitmap2 = _GDIPlus_BitmapCreateFromFile($s_dir & "\template.png")
$array2 = _myReadBitmapMsg($hBitmap2, 1)

$iMax = _GDIPlus_ImageGetWidth ($hBitmap1) / _GDIPlus_ImageGetWidth ($hBitmap2)

$t=TimerInit()
$aPosMsg = _ArrayComp($array1, $array2, False, $iMax)
ConsoleWrite("�ҵ�һ��ͼƬ����ȥʱ��:"&TimerDiff($t)&'����,λ����Ϣ(Ϊ��δ�ҵ�):'&$aPosMsg&@CRLF)

$t=TimerInit()
$aPosMsg = _ArrayComp($array1, $array2, True, $iMax)
ConsoleWrite("�ҵ�����ͼƬ����ȥʱ��:"&TimerDiff($t)&'����,λ����Ϣ(Ϊ��δ�ҵ�):'&$aPosMsg&@CRLF)

If $aPosMsg<>"" Then 
        Local $aPos, $i, $hGraphics = _GDIPlus_ImageGetGraphicsContext ($hBitmap1)
        $aPosMsg = StringSplit($aPosMsg,"|",2)
        For $i = 0 To UBound($aPosMsg)-1
                $aPos = StringSplit($aPosMsg[$i],",",2)
                _GDIPlus_GraphicsDrawRect($hGraphics, $aPos[0], $aPos[1], $aPos[2], $aPos[3])
        Next
        _GDIPlus_ImageSaveToFile($hBitmap1, $s_dir&"\Target.bmp")
        _GDIPlus_GraphicsDispose ($hGraphics)
EndIf

_GDIPlus_ImageDispose ($hBitmap1)
_WinAPI_DeleteObject ($hBitmap1)
_GDIPlus_ImageDispose ($hBitmap2)
_WinAPI_DeleteObject ($hBitmap2)
_GDIPlus_ShutDown ()
Exit

;һ����˵,��$hBitmap2��Сͼʱ$iType=1, �ϴ�ʱ$iType=0, �����֪$array2�ĸ�Ԫ�ؽ��������ȽϺ���,ֱ��ָ��Ϊ$iY
Func _ArrayComp($array1, $array2, $SearchAll=False, $iMax=0, $iY=0, $iType=0)
        Local $iExtended=0
        If $iMax>0 And $iY=0 Then
                Local $t=TimerInit()
                Local $sBmpData1 = ""
                For $i = 0 To UBound($array1)-1;�൱��_ArrayToString��_myReadBitmapMsg($hBitmap,0),������
                        $sBmpData1 &= $array1[$i]
                Next;===>�����$array2����ʱ,������ݿ�����udf��ִ��,_ArrayComp($sBmpData1, $array1, $array2, $SearchAll=False, $iMax=0, $iY=0, $iType=0)
                For $i = 0 To UBound($array2)-1
                        If StringReplace($array2[$i], StringLeft($array2[$i],6),"")="" Then ContinueLoop
                        Select
                                Case $iType = 0
                                        $iY = $i
                                        ExitLoop
                                #cs
                                Case $iType = 1 And Not @AutoItX64 ;pusofalse�ṩ�Ķ��̷߳���
                                        ;�÷�����ӳ���ļ������ݲ��� $pBaseAddress ���ñ��δ���
                                        Local $tBuff = DllStructCreate("char ["&StringLen($sBmpData1)+1&"]")
                                        DllStructSetData($tBuff, 1, $sBmpData1)
                                        $pBaseAddress = DllStructGetPtr($tBuff)
                                        ;http://www.autoitx.com/thread-20592-1-3.html
                                #ce
                                Case Else
                                        StringReplace($sBmpData1,$array2[$i],"",0, 1)
                                        If $iExtended=0 Or $iExtended>@extended Then 
                                                $iExtended=@extended
                                                If $iExtended=0 Then Return "";û��ƥ���ͼ��
                                                $iY = $i
                                                If $iExtended<=$iMax Then ExitLoop
                                        EndIf
                        EndSelect
                Next
                ConsoleWrite("��ȡ���������"&TimerDiff($t)&','&$iExtended&@CRLF)
        EndIf

        ;Local $t=TimerInit()
        If UBound($array1)<UBound($array2) Then Return ""
        Local $s_re="", $y, $y2, $iW2=StringLen($array2[$iY]), $iPos;, $iSearchPos
        For $y = $iy To UBound($array1)-1
                $iPos = 0;$iSearchPos = 1
                While $y+UBound($array2)<=UBound($array1)
                        $iPos = StringInStr($array1[$y], $array2[$iY], 1, 1, $iPos+1);$iPos = StringInStr($array1[$y], $array2[$iY], 1, 1, $iSearchPos)
                        Select
                        Case $iPos = 0
                                ContinueLoop(2)
                        Case Mod($iPos-1,6)<>0 ;Or $y<$iy
                                ;$iSearchPos = $iPos+1
                                ContinueLoop
                        EndSelect
                        For $y2 = $iY To UBound($array2)-1
                                If StringMid($array1[$y+$y2-$iy], $iPos, $iW2)<>$array2[$y2] Then
                                        ;$iSearchPos = $iPos+1
                                        ContinueLoop(2)
                                EndIf
                        Next
                        For $y2 = 0 To $iY-1
                                If StringMid($array1[$y+$y2-$iy], $iPos, $iW2)<>$array2[$y2] Then
                                        ;$iSearchPos = $iPos+1
                                        ContinueLoop(2)
                                EndIf
                        Next
                        $s_re &= ($iPos-1)/6&','&$y-$iy&','&$iW2/6&','&UBound($array2)&"|"
                        StringReplace($s_re,"|","")
                        If (Not $SearchAll) Or ($iExtended>0 And @extended>=$iExtended) Then ExitLoop(2)
                        ;$iSearchPos = $iPos+1
                WEnd
        Next
        If StringRight($s_re,1)="|" Then $s_re = StringTrimRight($s_re,1)
        ;ConsoleWrite(TimerDiff($t)&@CRLF);18
        Return $s_re
EndFunc

Func _myReadBitmapMsg($hBitmap, $iType=1);
	Local $aBmpData[5]
    $aBmpData[1] = _GDIPlus_ImageGetWidth ($hBitmap)
    $aBmpData[2] = _GDIPlus_ImageGetHeight ($hBitmap)
        Local $BitmapData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $aBmpData[1], $aBmpData[2], $GDIP_ILMREAD, $GDIP_PXF24RGB)
        $aBmpData[3] = Abs(DllStructGetData($BitmapData, "Stride"))
        $aBmpData[4] = DllStructGetData($BitmapData, "Scan0");
        _GDIPlus_BitmapUnlockBits($hBitmap, $BitmapData)
        Local $tBuff, $iH
        Switch $iType;�Ѳ��Ա�StringRegExp��
                Case -1
                        Return $aBmpData
                Case 0
                        For $iH = 1 To $aBmpData[2]
                                $tBuff = DllStructCreate("byte[" & ($aBmpData[1]*3) & "]", $aBmpData[4] + ($iH-1)*$aBmpData[3])
                                $aBmpData[0] &= StringTrimLeft(DllStructGetData($tBuff, 1),2)
                        Next
                        Return $aBmpData
                Case Else
                        Local $aRet[$aBmpData[2]]
                        For $iH = 1 To $aBmpData[2]
                                $tBuff = DllStructCreate("byte[" & ($aBmpData[1]*3) & "]", $aBmpData[4] + ($iH-1)*$aBmpData[3])
                                $aRet[$iH-1] = StringTrimLeft(DllStructGetData($tBuff, 1), 2)
                        Next
                        Return $aRet
        EndSwitch
EndFunc