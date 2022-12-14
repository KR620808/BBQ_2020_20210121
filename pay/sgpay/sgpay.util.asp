<%
	'-----------------------------------------------------------------------------
	' 로그 기록 함수 ( 디버그용 )
	' 사용 방법 : Call Write_Log(Log_String)
	' Log_String : 로그 파일에 기록할 내용
	'-----------------------------------------------------------------------------
	Const fsoForReading = 1		'- Open a file for reading. You cannot write to this file.
	Const fsoForWriting = 2		'- Open a file for writing.
	Const fsoForAppend = 8		'- Open a file and write to the end of the file.
	Sub Write_Log(Log_String)
		If Not LogUse Then Exit Sub
		'On Error Resume Next
		Dim oFSO
		Set oFSO = Server.CreateObject("Scripting.FileSystemObject")
		Dim oTextStream
		Set oTextStream = oFSO.OpenTextFile(Write_LogFile, fsoForAppend, True, 0)
		'-----------------------------------------------------------------------------
		' 내용 기록
		'-----------------------------------------------------------------------------
		oTextStream.WriteLine  CStr(FormatDateTime(Now,0)) + " " + Replace(CStr(Log_String),Chr(0),"'")
		'-----------------------------------------------------------------------------
		' 리소스 해제
		'-----------------------------------------------------------------------------
		oTextStream.Close
		Set oTextStream = Nothing
		Set oFSO = Nothing
	End Sub


	'-----------------------------------------------------------------------------
	' API 호출 함수( POST 전용)
	' 사용 방법 : Call_API(SiteURL, App_Mode, Param)
	' SiteURL : 호출할 API 주소
	' App_Mode : 데이터 전송 형태 ( 예: json, x-www-form-urlencoded 등 )
	' Param : 전송할 POST 데이터
	'-----------------------------------------------------------------------------
	Function Call_API(SiteURL, App_Mode, Param)
		Dim HTTP_Object

		'-----------------------------------------------------------------------------
		' WinHttpRequest 선언
		'-----------------------------------------------------------------------------
		Set HTTP_Object = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
		With HTTP_Object
			'API 통신 Timeout 을 30초로 지정
			.SetTimeouts 30000, 30000, 30000, 30000
			.Open "POST", SiteURL, False
			.SetRequestHeader "Content-Type", "application/x-www-form-urlencoded"
			'.SetRequestHeader "Content-Type", "application/"+CStr(App_Mode)+"; charset=UTF-8"
			'-----------------------------------------------------------------------------
			' API 전송 정보를 로그 파일에 저장
			'-----------------------------------------------------------------------------
			Call Write_Log("Call API   "+CStr(SiteURL)+" Mode : "  + CStr(App_Mode))
			Call Write_Log("Call API   "+CStr(SiteURL)+" Data : "  + CStr(Param))
			.Send Param
			.WaitForResponse
			'-----------------------------------------------------------------------------
			' 전송 결과를 리턴하기 위해 변수 선언 및 값 대입
			'-----------------------------------------------------------------------------
			Dim Result
			Set Result = New clsHTTP_Object
			Result.Status = CStr(.Status)
			Result.ResponseText = CStr(.ResponseText)
			'-----------------------------------------------------------------------------
			' API 전송 결과를 로그 파일에 저장
			'-----------------------------------------------------------------------------
			Call Write_Log("API Result "+CStr(SiteURL) + " Status : " + CStr(.Status))
			Call Write_Log("API Result "+CStr(SiteURL) + " ResponseText : " + CStr(.ResponseText))
		End With
		Set Call_API = Result
	End Function


	'-----------------------------------------------------------------------------
	' SGPAY 주문 취소 API 호출 함수
	' 사용 방법 : Call sgpay_cancel(mData)
	' mData - JSON 데이터
	'-----------------------------------------------------------------------------
	Function sgpay_cancel(mData)
		Dim Result, resultValue, tmpJSON
		Set Result = Call_API(sgPayCancelUrl, "json", mData)
		With Result
			Select Case .Status
				Case 200
					resultValue = .ResponseText
				Case Else
					Set tmpJSON = New aspJSON
					tmpJSON.data.Add "result", "주문 결제 취소 도중 오류가 발생하였습니다."
					tmpJSON.data.Add "message", .ResponseText
					tmpJSON.data.Add "code", .Status
					resultValue = tmpJSON.JSONoutput()
			End Select
		End With
		'결과 전달
		sgpay_cancel = resultValue
	End Function


	'-----------------------------------------------------------------------------
	' SGPAY 정산 API 호출 함수
	' 사용 방법 : Call sgpay_calculate(mData)
	' mData - JSON 데이터
	'-----------------------------------------------------------------------------
	Function sgpay_calculate(mData)
		Dim Result, resultValue, tmpJSON
		Set Result = Call_API(sgPayCalculateUrl, "json", mData)
		With Result
			Select Case .Status
				Case 200
					resultValue = .ResponseText
				Case Else
					Set tmpJSON = New aspJSON
					tmpJSON.data.Add "result", "정산 도중 오류가 발생하였습니다."
					tmpJSON.data.Add "message", .ResponseText
					tmpJSON.data.Add "code", .Status
					resultValue = tmpJSON.JSONoutput()
			End Select
		End With
		'결과 전달
		sgpay_calculate = resultValue
	End Function


	'-----------------------------------------------------------------------------
	' API 결과 전송용 데이터 구조 선언
	' Status 와 ResponseText 만을 전송한다.
	'-----------------------------------------------------------------------------
	Class clsHTTP_Object
		private m_Status
		private m_ResponseText

		public property get Status()
			Status = m_Status
		end property

		public property get ResponseText()
			ResponseText = m_ResponseText
		end property

		public property let Status(p_Status)
			m_Status = p_Status
		end property

		public property let ResponseText(p_ResponseText)
			m_ResponseText = p_ResponseText
		end property

		Private Sub Class_Initialize
			m_Status = ""
			m_ResponseText = ""
		End Sub
	End Class


	'-----------------------------------------------------------------------------
	' 회원번호 랜덤 생성
	'-----------------------------------------------------------------------------
	Function rndNum(intLength)
		num = ""
		For i = 1 to intLength
			Randomize                '//랜덤을 초기화 한다.
			num = num & CInt(Rnd*9)    '//랜덤 숫자를 만든다.
		Next
		rndNum = num
	End Function
%>