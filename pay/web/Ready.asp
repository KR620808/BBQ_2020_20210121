<!--#include virtual="/api/include/utf8.asp"-->
<%
    Session.CodePage = "949"
    Response.AddHeader "Pragma", "no-cache"
    Response.CacheControl = "no-cache"
    Response.CharSet = "EUC-KR"
  
	'/********************************************************************************
	' *
	' * 다날 본인인증
	' *
	' * - 인증 요청 페이지
	' *      CP인증 및 기타 정보 전달
	' *
	' * 시스템 연동에 대한 문의사항이 있으시면 서비스개발팀으로 연락 주십시오.
	' * DANAL Commerce Division Technique supporting Team
	' * EMail : tech@danal.co.kr
	' *
	' ********************************************************************************/

    '/********************************************************************************
	' *
	' * XSS 취약점 방지를 위해 
	' * 모든 페이지에서 파라미터 값에 대해 검증하는 로직을 추가할 것을 권고 드립니다.
	' * XSS 취약점이 존재할 경우 웹페이지를 열람하는 접속자의 권한으로 부적절한 스크립트가 수행될 수 있습니다.
	' * 보안 대책
	' *  - html tag를 허용하지 않아야 합니다.(html 태그 허용시 white list를 선정하여 해당 태그만 허용)
	' *  - <, >, &, " 등의 문자를 replace등의 문자 변환함수를 사용하여 치환해야 합니다.
	' * 
	' ********************************************************************************/
%>
<!--#include file="inc/function.asp"-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>다날 본인인증</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr" />
</head>
<%
	Dim TransR

	'/********************************************************************************
	' *
	' * [ 전문 요청 데이터 ] *********************************************************
	' *
	' ********************************************************************************/

	'/***[ 필수 데이터 ]************************************/
	Set ByPassValue = CreateObject("Scripting.Dictionary")
	Set TransR = CreateObject("Scripting.Dictionary")

	'/******************************************************
	' ** 아래의 데이터는 고정값입니다.( 변경하지 마세요 )
	' * TXTYPE	: ITEMSEND
	' * SERVICE	: UAS
	' * AUTHTYPE	: 36
	' ******************************************************/
	TransR.Add "TXTYPE", "ITEMSEND"
	TransR.Add "SERVICE", "UAS"
	TransR.Add "AUTHTYPE", "36"

	'/******************************************************
	' * CPID 	 : 다날에서 제공해 드린 ID( function 파일 참조 )
	' * CPPWD	 : 다날에서 제공해 드린 PWD( function 파일 참조 )
	' * TARGETURL : 인증 완료 시 이동 할 페이지의 FULL URL
	' * CPTITLE   : 가맹점의 대표 URL 혹은 APP 이름 
	' ******************************************************/
	TransR.Add "CPID", ID
	TransR.Add "CPPWD", PWD
	TransR.Add "TargetURL", GetCurrentHost& "/pay/web/CPCGI.asp"& param_str
	TransR.Add "CPTITLE", GetCurrentHost

	'/***[ 선택 사항 ]**************************************/
	'/******************************************************
	' * USERID	: 사용자 ID
	' * ORDERID	: CP 주문번호	
	' * AGELIMIT	: 서비스 사용 제한 나이 설정( 가맹점 필요 시 사용 )
	' ******************************************************/
	TransR.Add "USERID", "USERID"
	TransR.Add "ORDERID", "ORDERID"
	' TransR.Add "AGELIMIT", "019"

	
	'/********************************************************************************
	' *
	' * [ CPCGI에 HTTP POST로 전달되는 데이터 ] **************************************
	' *
	' ********************************************************************************/

	'/***[ 필수 데이터 ]************************************/
	Dim ByPassValue

	'/******************************************************
	' * BgColor	: 인증 페이지 Background Color 설정
	' * BackURL	: 에러 발생 및 취소 시 이동 할 페이지의 FULL URL
	' * IsCharSet	: charset 지정( EUC-KR:deault, UTF-8 )
	' ******************************************************/
	ByPassValue.Add "BgColor", "00"
	ByPassValue.Add "BackURL", GetCurrentHost& "/pay/web/BackURL.asp"
	ByPassValue.Add "IsCharSet", CHARSET
	
	'/***[ 선택 사항 ]**************************************/
	'/******************************************************
	' ** CPCGI에 POST DATA로 전달 됩니다.
	' **
	' ******************************************************/  
	ByPassValue.Add "ByBuffer", "This value bypass to CPCGI Page"
	ByPassValue.Add "ByAnyName", "AnyValue"
	
	Set Res = CallTrans( TransR,false )
	
	IF Res.Item("RETURNCODE") = "0000" Then
%>
<body>
<form name="Ready" action="https://wauth.teledit.com/Danal/WebAuth/Web/Start.php" method="post">
<%
MakeFormInput Res , Array("RETURNCODE","RETURNMSG")
MakeFormInput ByPassValue , null
%>
</form>
<script Language="JavaScript">
	document.Ready.submit();
</script>
</body>
</html>
<%
	Else
		'/**************************************************************************
		' *
		' * 인증 실패에 대한 작업
		' *
		' **************************************************************************/  
		RETURNCODE 	= Res.Item("RETURNCODE")
		RETURNMSG 	= Res.Item("RETURNMSG")
		AbleBack 	= false
		BackURL 	= ByPassValue.Item("BackURL")
		BgColor 	= ByPassValue.Item("BgColor")
%>
		<!--#include file = "Error.asp"-->
<%
	End IF
%>