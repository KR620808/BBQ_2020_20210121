<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%
    Session.CodePage = "65001"
    Response.AddHeader "Pragma", "no-cache"
    Response.CacheControl = "no-cache"
    Response.CharSet = "EUC-KR"
%>
<!--#include virtual="/api/include/cv.asp"-->
<!--#include virtual="/api/include/db_open.asp"-->
<!--#include virtual="/api/include/func.asp"-->
<!--#include file="./inc/function.asp"-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr"/>
<link href="./css/style.css" type="text/css" rel="stylesheet" media="all" />
<title>*** 신용카드 결제 요청***</title>
</head>
<body>
<%
    order_idx = GetReqNum("order_idx", "")
    order_num = GetReqStr("order_num","")
    pay_method = GetReqStr("pay_method","")

    response.Cookies("ORDER_IDX") = order_idx
    
    Set pCmd = Server.CreateObject("ADODB.Command")
    With pCmd
        .ActiveConnection = dbconn
        .NamedParameters = True
        .CommandType = adCmdStoredProc
        .CommandText = "bp_order_for_pay"

        .Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput, , order_idx)

        Set pRs = .Execute
    End With
    Set pCmd = Nothing

    If Not (pRs.BOF Or pRs.EOF) Then
        USER_ID = pRs("member_idno")
        SUBCPID = pRs("danal_h_scpid")
        AMOUNT = pRs("order_amt")+pRs("delivery_fee")
    Else
        USER_ID = ""
        SUBCPID = ""
        AMOUNT = ""
    End If

	Dim REQ_DATA, RES_DATA				' 변수 선언
    
	'*[ 필수 데이터 ]**************************************
	Set REQ_DATA	= CreateObject("Scripting.Dictionary")

    '******************************************************
	'*  RETURNURL 	: CPCGI페이지의 Full URL을 넣어주세요
	'*  CANCELURL 	: BackURL페이지의 Full URL을 넣어주세요
	'******************************************************/
    RETURNURL = GetCurrentHost& "/pay/danal_card/CPCGI.asp"
    CANCELURL = GetCurrentHost& "/pay/danal_card/Cancel.asp"

    '**************************************************
    '* SubCP 정보
	'**************************************************/
    REQ_DATA.Add "SUBCPID", SUBCPID

    '**************************************************
	'* 결제 정보
	'**************************************************/
    REQ_DATA.Add "AMOUNT", AMOUNT
    REQ_DATA.Add "CURRENCY", "410"
    REQ_DATA.Add "ITEMNAME", "BBQ Chicken"
    REQ_DATA.Add "USERAGENT", "PC"
    REQ_DATA.Add "ORDERID", order_num
    REQ_DATA.Add "OFFERPERIOD", ""

    '**************************************************
	'* 고객 정보
	'**************************************************/
    REQ_DATA.Add "USERNAME", USER_ID '// 구매자 이름
    REQ_DATA.Add "USERID", USER_ID '// 사용자 ID
    REQ_DATA.Add "USEREMAIL", "" '// 소보법 email수신처

    '**************************************************
	'* URL 정보
	'**************************************************/
    REQ_DATA.Add "CANCELURL", CANCELURL
    REQ_DATA.Add "RETURNURL", RETURNURL

    '**************************************************
	'* 기본 정보
	'**************************************************/
    REQ_DATA.Add "TXTYPE", "AUTH"
    REQ_DATA.Add "SERVICETYPE", "DANALCARD"
    REQ_DATA.Add "ISNOTI", "N"
    REQ_DATA.Add "BYPASSVALUE", "this=is;a=test;bypass=value" '// BILL응답 또는 Noti에서 돌려받을 값. '&'를 사용할 경우 값이 잘리게되므로 유의.

' ISDEBUG = TRUE
    if ISDEBUG Then
        FOR EACH key IN REQ_DATA
            Response.Write(key & " / " & REQ_DATA.Item(key) & "<br>" & chr(13) & chr(10))
        NEXT
    end if


	Set RES_DATA = CallCredit(REQ_DATA, false)
	
	IF RES_DATA.Item("RETURNCODE") = "0000" Then
%>
<form name="form" ACTION="<%=RES_DATA.Item("STARTURL")%>" METHOD="POST" >
    <input TYPE="HIDDEN" NAME="STARTPARAMS"  	VALUE="<%=RES_DATA.Item("STARTPARAMS")%>">
    <input TYPE="HIDDEN" NAME="CIURL"   VALUE="<%=GetCurrentHost%>/images/common/logo_header_bbq.png">
    <input TYPE="HIDDEN" NAME="COLOR"   VALUE="#FFFFFF">
</form>
<script>
    document.form.submit();
</script>
<%
	Else
		RETURNCODE	= RES_DATA.Item("RETURNCODE")
		RETURNMSG		= RES_DATA.Item("RETURNMSG")
		CANCELURL		= REQ_DATA.Item("CANCELURL")
%>
		<!--#include file="Error.asp"-->
<%
	End if

    ' DB 닫기
    DBclose()
%>
</body>
</html>
