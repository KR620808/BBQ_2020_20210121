<!--#include virtual="/api/include/utf8.asp"-->
<%
	'Option Explicit
	'-----------------------------------------------------------------------------
	' SGPAY 연동 환경설정 페이지 ( ASP )
	' sgpay.inc.asp
	' 2019-12-10	Sewoni31™
	'
	' ASP 에서는 JSON 형태를 지원하지 않기 때문에 하단 파일(json/JSON_2.0.4.asp)을 include 합니다.
	'-----------------------------------------------------------------------------
%>
<!--#include file="sgpay.util.asp"-->
<!--#include file="json/aspJSON1.17.asp"-->
<%
	'---------------------------------------------------------------------------------
	'
	' 환경변수 선언
	'
	'-----------------------------------------------------------------------------
	Dim AppWebPath

	'---------------------------------------------------------------------------------
	' 가맹점 API 가 호출 당할 경우 도메인 또는 아이피 셋팅하기 위한 변수 ( 도메인이 있을 경우 도메인을 셋팅하시면 됩니다. )
	' 용도 : serviceUrl 및 returnUrl, nonBankbookDepositInformUrl 용.
	' API 호출시 http:// 부터 경로를 전체적으로 써줘야 HttpRequest 통신시 오류발생 안함.
	'---------------------------------------------------------------------------------
	If Request.ServerVariables("HTTPS") = "on" Then
		urlProtocol = "https"
	Else
		urlProtocol = "http"
	End If

	AppWebPath = urlProtocol & "://" & Request.ServerVariables("HTTP_HOST")

	'-----------------------------------------------------------------------------
	' 캐릭터셋 지정
	'-----------------------------------------------------------------------------
	Response.charset = "UTF-8"


	'-----------------------------------------------------------------------------
	' USER-AGENT 구분
	'-----------------------------------------------------------------------------
	WebMode = Request.ServerVariables("HTTP_USER_AGENT")
	If Not (InStr(LCase(WebMode),"android") = 0 And InStr(LCase(WebMode),"iphone") = 0 And InStr(LCase(WebMode),"mobile") = 0) Then
		WebMode = "MOBILE"
	Else
		WebMode = "PC"
	End If


	'---------------------------------------------------------------------------------
	' 운영/개발 설정
	' Log 사용 여부 설정
	'---------------------------------------------------------------------------------
	Dim appMode, LogUse
	'appMode = "-test"		' REAL - 실서버 운영, TEST - 개발(테스트)
	LogUse = True			' Log 사용 여부 ( True = 사용, False = 미사용 )


	'-----------------------------------------------------------------------------
	' 가맹점 코드 선언
	'-----------------------------------------------------------------------------
	Dim corporationToken, merchantToken
	'corporationToken = "BDC2936F9E2C4AD4ABD47BDEB29DFE47"			' 기업 관리번호(토큰)
	If G2_SITE_MODE = "local" Then
		corporationToken = "B6C3DAF451954724904D4D39F38E5B13"			' 기업 관리번호(토큰)
	Else
		corporationToken = "5A51EDCC4FEC4D4A9E4C67B09AD26B74"			' 기업 관리번호(토큰)
	End If


	'---------------------------------------------------------------------------------
	' 로그 파일 선언 ( 루트경로부터 \sgpay\log 폴더까지 생성을 해 놓습니다. )
	'---------------------------------------------------------------------------------
	Dim Write_LogFile
	Write_LogFile = Server.MapPath(".") + "\log\sgpay_Log_"+Replace(FormatDateTime(Now,2),"-","")+"_asp.txt"


	'-----------------------------------------------------------------------------
	' 암호화 모듈 및 키 선언
	'-----------------------------------------------------------------------------
	Set Com = server.createobject("Stargate.TokenCrypto")
	secretKey = "1234567890123456" ' 16 length


	'-----------------------------------------------------------------------------
	' 토큰 생성 및 암호화 코드 선언
	'-----------------------------------------------------------------------------
	Dim token
	Dim tokenToJson, encryptedJson


	'---------------------------------------------------------------------------------
	' 구매 상품을 변수에 셋팅 ( JSON 문자열을 생성 )
	'---------------------------------------------------------------------------------
	Set jsonOrder = New aspJson			'JSON 을 작성할 OBJECT 선언
	jsonOrder.data.Add "Corporation", CStr(corporationToken)
	memberToken =  Session("userIdNo")
	jsonOrder.data.Add "Member", memberToken


	'---------------------------------------------------------------------------------
	' API 주소 설정 ( appMode 에 따라 테스트와 실서버로 분기됩니다. )
	'---------------------------------------------------------------------------------
	Dim sgPayDomain, sgPayMainUrl, sgPayPayUrl, sgPayCancelUrl, sgPayCalculateUrl
	'sgPayDomain			= "https://dev-sg.seeroo.info"				' 개발서버
	If G2_SITE_MODE = "local" Then
		sgPayDomain			= "https://stg-stargate.kbstar.com"		' 운영 테스트서버
	Else
		sgPayDomain			= "https://stargate.kbstar.com"					' 운영 실서버
	End If
	sgPayMainUrl			= sgPayDomain & "/pay" & appMode & "/?token="							' SG Pay 메인 URL
	sgPayPayUrl			= sgPayDomain & "/pay" & appMode & "/pay/info.html?token="		' SG Pay 결제 URL
	sgPayCancelUrl		= sgPayDomain & "/pay-api" & appMode & "/pay/cancel"					' SG Pay 취소 URL
	sgPayCalculateUrl	= sgPayDomain & "/pay-api" & appMode & "/pay/calculate"				' SG Pay 경산 URL
%>