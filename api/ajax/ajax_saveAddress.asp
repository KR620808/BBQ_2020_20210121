<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%
    Response.CharSet = "UTF-8"
%>
<!--#include virtual="/api/include/cv.asp"-->
<!--#include virtual="/api/include/db_open.asp"-->
<!--#include virtual="/api/include/func.asp"-->
<%
	REFERERURL	= Request.ServerVariables("HTTP_REFERER")
	If left(REFERERURL,19) = left(GetCurrentHost,19) Then 
	Else 
		Response.Write "{""success"":false, ""addr_idx"":0}"
		Response.End 
	End If

    ' Response.Write "member_idx : " & Session("member_idx") & ", member_idno : " & Session("member_idno")
    Dim result
    Dim vMode : vMode = Request("mode")
    Dim vAddrIdx : vAddrIdx = Request("addr_idx")
    Dim vAddrName : vAddrName = Request("addr_name")
    Dim vZipCode : vZipCode = Request("zip_code")
    Dim vAddrType : vAddrType = Request("addr_type")
    Dim vAddrJibun : vAddrJibun = Request("address_jibun")
    Dim vAddrRoad : vAddrRoad = Request("address_road")
    Dim vAddrDetail : vAddrDetail = Request("address_detail")
    Dim vSido : vSido = Request("sido")
    Dim vSigungu : vSigungu = Request("sigungu")
    Dim vSigunguCode : vSigunguCode = Request("sigungu_code")
    Dim vRoadNameCode : vRoadNameCode = Request("roadname_code")
    Dim vBName : vBName = Request("b_name")
    Dim vBCode : vBCode = Request("b_code")
    Dim vMobile : vMobile = Request("mobile")
    Dim vHCode : vHCode = Request("h_code") '행정동 코드 추가 (2022. 3. 22)
    Dim vLat : vLat = Request("lat") '위경도 추가 (2022. 5. 11)
    Dim vLng : vLng = Request("lng") '위경도 추가 (2022. 5. 11)

    If IsEmpty(vMode) Or IsNull(vMode) Or Trim(vMode) = "" Then vMode = "" End If
    If IsEmpty(vAddrIdx) Or IsNull(vAddrIdx) Or Trim(vAddrIdx) = "" Then vAddrIdx = 0 End If
    If IsEmpty(vAddrName) Or IsNull(vAddrName) Or Trim(vAddrName) = "" Then vAddrName = "" End If
    If IsEmpty(vZipCode) Or IsNull(vZipCode) Or Trim(vZipCode) = "" Then vZipCode = "" End If
    If IsEmpty(vAddrType) Or IsNull(vAddrType) Or Trim(vAddrType) = "" Then vAddrType = "" End If
    If IsEmpty(vAddrJibun) Or IsNull(vAddrJibun) Or Trim(vAddrJibun) = "" Then vAddrJibun = "" End If
    If IsEmpty(vAddrRoad) Or IsNull(vAddrRoad) Or Trim(vAddrRoad) = "" Then vAddrRoad = "" End If
    If IsEmpty(vAddrDetail) Or IsNull(vAddrDetail) Or Trim(vAddrDetail) = "" Then vAddrDetail = "" End If
    If IsEmpty(vSido) Or IsNull(vSido) Or Trim(vSido) = "" Then vSido = "" End If
    If IsEmpty(vSigungu) Or IsNull(vSigungu) Or Trim(vSigungu) = "" Then vSigungu = "" End If
    If IsEmpty(vSigunguCode) Or IsNull(vSigunguCode) Or Trim(vSigunguCode) = "" Then vSigunguCode = "" End If
    If IsEmpty(vRoadNameCode) Or IsNull(vRoadNameCode) Or Trim(vRoadNameCode) = "" Then vRoadNameCode = "" End If
    If IsEmpty(vBName) Or IsNull(vBName) Or Trim(vBName) = "" Then vBName = "" End If
    If IsEmpty(vBCode) Or IsNull(vBCode) Or Trim(vBCode) = "" Then vBCode = "" End If
    If IsEmpty(vMobile) Or IsNull(vMobile) Or Trim(vMobile) = "" Then vMobile = "" End If
    If IsEmpty(vHCode) Or IsNull(vHCode) Or Trim(vHCode) = "" Then vHCode = "" End If '행정동 코드 추가 (2022. 3. 22)
    If IsEmpty(vLat) Or IsNull(vLat) Or Trim(vLat) = "" Then vLat = "0" End If '위경도 추가 (2022. 5. 11)
    If IsEmpty(vLng) Or IsNull(vLng) Or Trim(vLng) = "" Then vLng = "0" End If '위경도 추가 (2022. 5. 11)

    Dim aCmd, aRs, ErrCode, ErrMsg

    If Session("userIdx") = "" Then 
        result = "{""success"":false, ""addr_idx"":0}"
        
    ElseIf vMode = "I" Then
        Set aCmd = Server.CreateObject("ADODB.Command")

        With aCmd
            .ActiveConnection = dbconn
            .NamedParameters = True
            .CommandType = adCmdStoredProc
            .CommandText = "bp_member_addr_insert"

            .Parameters.Append .CreateParameter("@member_idx", adInteger, adParamInput, , Session("userIdx"))
            .Parameters.Append .CreateParameter("@member_idno", adVarChar, adParamInput, 50, Session("userIdNo"))
            .Parameters.Append .CreateParameter("@member_type", adVarChar, adParamInput, 10, Session("userType"))
            .Parameters.Append .CreateParameter("@addr_name", adVarChar, adParamInput, 100, vAddrName)
            .Parameters.Append .CreateParameter("@zip_code", adVarChar, adParamInput, 10, vZipCode)
            .Parameters.Append .CreateParameter("@addr_type", adVarChar, adParamInput, 1, vAddrType)
            .Parameters.Append .CreateParameter("@address_jibun", adVarChar, adParamInput, 1000, vAddrJibun)
            .Parameters.Append .CreateParameter("@address_road", adVarChar, adParamInput, 1000, vAddrRoad)
            .Parameters.Append .CreateParameter("@address_detail", adVarChar, adParamInput, 100, vAddrDetail)
            .Parameters.Append .CreateParameter("@sido", adVarChar, adParamInput, 100, vSido)
            .Parameters.Append .CreateParameter("@sigungu", adVarChar, adParamInput, 100, vSigungu)
            .Parameters.Append .CreateParameter("@sigungu_code", adVarChar, adParamInput, 10, vSigunguCode)
            .Parameters.Append .CreateParameter("@roadname_code", adVarChar, adParamInput, 10, vRoadNameCode)
            .Parameters.Append .CreateParameter("@bname", adVarChar, adParamInput, 100, vBName)
            .Parameters.Append .CreateParameter("@b_code", adVarChar, adParamInput, 20, vBCode)
            .Parameters.Append .CreateParameter("@mobile", adVarChar, adParamInput, 20, vMobile)
            .Parameters.Append .CreateParameter("@h_code", adVarChar, adParamInput, 20, vHCode) '행정동 코드 추가 (2022. 3. 22)
            .Parameters.Append .CreateParameter("@lat", adVarChar, adParamInput, 20, vLat) '위경도 추가 (2022. 5. 11)
            .Parameters.Append .CreateParameter("@lng", adVarChar, adParamInput, 20, vLng) '위경도 추가 (2022. 5. 11)
            .Parameters.Append .CreateParameter("@ERRCODE", adInteger, adParamOutput)
            .Parameters.Append .CreateParameter("@ERRMSG", adVarChar, adParamOutput, 500)

            Set aRs = .Execute

            ErrCode = .Parameters("@ERRCODE").Value
            ErrMsg = .Parameters("@ERRMSG").Value
        End With
        Set aCmd = Nothing

        If Not (aRs.BOF Or aRs.EOF) Then
            aRs.MoveFirst

            addr_idx = Cdbl(aRs("addr_idx"))
        End If
        Set aRs = Nothing

        If addr_idx > 0 And ErrCode = 0 Then
            result = "{""success"":true, ""addr_idx"":" & addr_idx &"}"
        Else
            result = "{""success"":false, ""addr_idx"":0}"
        End If
    ElseIf vMode = "U" Then
        Set aCmd = Server.CreateObject("ADODB.Command")

        With aCmd
            .ActiveConnection = dbconn
            .NamedParameters = True
            .CommandType = adCmdStoredProc
            .CommandText = "bp_member_addr_update"

            .Parameters.Append .CreateParameter("@addr_idx", adInteger, adParamInput, , vAddrIdx)
            .Parameters.Append .CreateParameter("@member_idx", adInteger, adParamInput, , Session("userIdx"))
            .Parameters.Append .CreateParameter("@member_idno", adVarChar, adParamInput, 50, Session("userIdNo"))
            .Parameters.Append .CreateParameter("@member_type", adVarChar, adParamInput, 10, Session("userType"))
            .Parameters.Append .CreateParameter("@addr_name", adVarChar, adParamInput, 100, vAddrName)
            .Parameters.Append .CreateParameter("@zip_code", adVarChar, adParamInput, 10, vZipCode)
            .Parameters.Append .CreateParameter("@addr_type", adVarChar, adParamInput, 1, vAddrType)
            .Parameters.Append .CreateParameter("@address_jibun", adVarChar, adParamInput, 1000, vAddrJibun)
            .Parameters.Append .CreateParameter("@address_road", adVarChar, adParamInput, 1000, vAddrRoad)
            .Parameters.Append .CreateParameter("@address_detail", adVarChar, adParamInput, 100, vAddrDetail)
            .Parameters.Append .CreateParameter("@sido", adVarChar, adParamInput, 100, vSido)
            .Parameters.Append .CreateParameter("@sigungu", adVarChar, adParamInput, 100, vSigungu)
            .Parameters.Append .CreateParameter("@sigungu_code", adVarChar, adParamInput, 10, vSigunguCode)
            .Parameters.Append .CreateParameter("@roadname_code", adVarChar, adParamInput, 10, vRoadNameCode)
            .Parameters.Append .CreateParameter("@bname", adVarChar, adParamInput, 100, vBName)
            .Parameters.Append .CreateParameter("@b_code", adVarChar, adParamInput, 20, vBCode)
            .Parameters.Append .CreateParameter("@mobile", adVarChar, adParamInput, 20, vMobile)
            .Parameters.Append .CreateParameter("@h_code", adVarChar, adParamInput, 20, vHCode) '행정동 코드 추가 (2022. 3. 22)
            .Parameters.Append .CreateParameter("@lat", adVarChar, adParamInput, 20, vLat) '위경도 추가 (2022. 5. 11)
            .Parameters.Append .CreateParameter("@lng", adVarChar, adParamInput, 20, vLng) '위경도 추가 (2022. 5. 11)
            .Parameters.Append .CreateParameter("@ERRCODE", adInteger, adParamOutput)
            .Parameters.Append .CreateParameter("@ERRMSG", adVarChar, adParamOutput, 500)

            Set aRs = .Execute

            ErrCode = .Parameters("@ERRCODE").Value
            ErrMsg = .Parameters("@ERRMSG").Value
        End With
        Set aCmd = Nothing

        If Not (aRs.BOF Or aRs.EOF) Then
            aRs.MoveFirst

            addr_idx = Cdbl(aRs("addr_idx"))
        End If
        Set aRs = Nothing

        If addr_idx > 0 And ErrCode = 0 Then
            result = "{""success"":true, ""addr_idx"":" & addr_idx &"}"
        Else
            result = "{""success"":false, ""addr_idx"":0}"
        End If
    ElseIf vMode = "D" Then
        Set aCmd = Server.CreateObject("ADODB.Command")

        With aCmd
            .ActiveConnection = dbconn
            .NamedParameters = True
            .CommandType = adCmdStoredProc
            .CommandText = "bp_member_addr_delete"

            .Parameters.Append .CreateParameter("@addr_idx", adInteger, adParamInput, , vAddrIdx)
            .Parameters.Append .CreateParameter("@member_idno", adVarChar, adParamInput, 50, Session("userIdNo"))
            .Parameters.Append .CreateParameter("@ERRCODE", adInteger, adParamOutput)
            .Parameters.Append .CreateParameter("@ERRMSG", adVarChar, adParamOutput, 500)

            .Execute

            ErrCode = .Parameters("@ERRCODE").Value
            ErrMsg = .Parameters("@ERRMSG").Value
        End With
        Set aCmd = Nothing

        If ErrCode = 0 Then
            result = "{""success"":true, ""addr_idx"":" & addr_idx &"}"
        Else
            result = "{""success"":false, ""addr_idx"":0}"
        End If
    End If


    Response.Write result
%>