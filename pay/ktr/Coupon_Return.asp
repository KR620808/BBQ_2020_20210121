<!--#include virtual="/api/include/utf8.asp"-->
<!--#include virtual="/pay/coupon_use.asp"-->
<!--#include virtual="/pay/coupon_use_coop.asp"-->
<!--#include virtual="/api/order/class_order_db.asp"-->
<!--#include virtual="/api/include/aspJSON1.18.asp"-->
<!--#include virtual="/api/include/inc_encrypt.asp"-->
<%
	Dim aCmd, aRs

	Dim order_idx : order_idx = Request("order_idx")
	Dim paytype : paytype = Request("pm")
	Dim eCouponType : eCouponType = ""

	'response.write order_idx 
	'response.end 

	If IsEmpty(order_idx) Or IsNull(order_idx) Or Trim(order_idx) = "" Or Not IsNumeric(order_idx) Then order_idx = ""

	If order_idx = "" Or paytype = "" Then
%>
	<script type="text/javascript">
		alert("잘못된 접근입니다.");
		self.close();
	</script>
<%
		Response.End
	End If

	Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','['+convert(varchar(19), getdate() , 120) + '] start','0','Coupon_Return-000')"
	dbconn.Execute(Sql)

	dim pg_RollBack : pg_RollBack = 0
	dim cl_eCoupon : set cl_eCoupon = new eCoupon
	dim cl_eCouponCoop : set cl_eCouponCoop = new eCouponCoop

	dim db_call : set db_call = new Order_DB_Call
	db_call.DB_Order_State dbconn, order_idx, "P", paytype

	Set aCmd = Server.CreateObject("ADODB.Command")

'    response.write "order_idx : "& order_idx & "<BR>"
	With aCmd
		.ActiveConnection = dbconn
		.NamedParameters = True
		.CommandType = adCmdStoredProc
		.CommandText = "bp_order_select_one"

		.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput,,order_idx)

		Set aRs = .Execute
	End With
	Set aCmd = Nothing

	Dim order_num, order_date, order_amt, discount_amt, pay_amt, delivery_fee, order_type
	Dim branch_id, branch_name, branch_phone, branch_tel, addr_name, zipcode, address_main, address_detail, delivery_message, delivery_mobile
	Dim spent_time
	If Not (aRs.BOF Or aRs.EOF) Then
		order_idx = aRs("order_idx")
		order_num = aRs("order_num")
		order_type = aRs("order_type")
		member_idx = aRs("member_id")
		member_idno = aRs("member_idno")
		member_type = aRs("member_type")
		pay_type = aRs("pay_type")
		order_date = aRs("order_date")
		order_amt = aRs("order_amt")
		delivery_fee = aRs("delivery_fee")
		discount_amt = aRs("discount_amt")
		pay_amt = aRs("pay_amt")
		delivery_fee = aRs("delivery_fee")
		branch_id = aRs("branch_id")
		brand_code = aRs("brand_code")
		branch_name = aRs("branch_name")
		branch_phone = aRs("branch_phone")
		branch_tel = aRs("branch_tel")
		addr_name = aRs("addr_name")
		zipcode = aRs("delivery_zipcode")
		address_main = aRs("delivery_address")
		address_detail = aRs("delivery_address_detail")
		delivery_message = aRs("delivery_message")
		delivery_mobile = aRs("delivery_mobile")
		spent_time = aRs("spent_time")
		order_channel = aRs("order_channel")
		MENU_NAME		= aRs("MENU_NAME")
		If order_channel = "2" Or order_channel = "3"  Then
			order_channel = "WEB"
		Else
			order_channel = "APP"
		End If
	End If
	Set aRs = Nothing

    'giftcard_serial = Request.Cookies("giftcardSerial")  ' paymenu_proc.asp 에서 
	
	'Response.Write "giftcardSerial ::: " & Request.Cookies("giftcardSerial") & "<BR>"
	'Response.Write "giftcard_serial ::: " & Request.Cookies("giftcard_serial") & "<BR>"

	' 2021-07 더페이 상품권 주석 처리 시작

    'If giftcard_serial <> "" Then
    '    ' 상품권 조회
    '    Set httpRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
    '    httpRequest.Open "GET", "http://api.bbq.co.kr/GiftCard_2.svc/GetGiftCard/"& giftcard_serial, False
    '    httpRequest.SetRequestHeader "AUTH_KEY", "BF84B3C90590"
    '    httpRequest.SetRequestHeader "Content-Type", "application/x-www-form-urlencoded"
    '    httpRequest.Send
    '    '상품권 조회
    '    '조회 상품권 text -> json
    '    Set oJSON = New aspJSON
    '    postResponse = "{""list"" : " & httpRequest.responseText & "}"
    '    oJSON.loadJSON(postResponse)
    '    Set this = oJSON.data("list")
    '    U_CD_BRAND = brand_code '사용브랜드코드
    '    U_CD_PARTNER = branch_id ' 사용매장코드
    '    AMT = this.item("AMT") ' 금액
    '    U_YN = this.item("U_YN") ' 사용여부
    '    '조회 상품권 text -> json
	'
    '    ' 상품권 사용처리 data set
    '    If U_YN = "N" Then
    '        data = "{"
    '        data = data & """U_CD_BRAND"":""" & U_CD_BRAND & ""","
    '        data = data & """U_CD_PARTNER"":""" & U_CD_PARTNER & ""","
    '        data = data & """AMT"":""" & AMT & """"
    '        data = data & "}"
    '        ' 상품권 사용처리 data set
    '        Set httpRequest = nothing ' 초기화
    '        ' 상품권 사용처리
    '        Set httpRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
    '        httpRequest.Open "POST", "http://api.bbq.co.kr/GiftCard_2.svc/UseGiftCard/"& giftcard_serial, False
    '        httpRequest.SetRequestHeader "AUTH_KEY", "BF84B3C90590"
    '        'httpRequest.SetRequestHeader "Content-Type", "application/raw"
    '        httpRequest.Send data
    '        'Response.Write httpRequest.responseText
    '        'Response.Write data
    '        ' 상품권 사용처리
    '        '조회 상품권 text -> json
    '        Set gJSON = New aspJSON
    '        gpostResponse = "{""list"" : " & httpRequest.responseText & "}"
    '        gJSON.loadJSON(gpostResponse)
    '        Set this1 = gJSON.data("list")
	'
    '        U_CD_BRAND = this1.item("U_CD_BRAND") '사용브랜드코드
    '        U_CD_PARTNER = this1.item("U_CD_PARTNER") ' 사용매장코드
    '        OK_NUM = this1.item("OK_NUM") ' 승인번호
    '        RTN_CD = this1.item("RTN_CD") ' 결과코드
    '        RTN_MSG = this1.item("RTN_MSG") ' 결과코드
    '        'Response.Write U_CD_BRAND& "브랜드코드<BR>"
    '        'Response.Write U_CD_PARTNER& "매장코드<BR>"
    '        'Response.Write order_num& "주문번호<BR>"
    '        '조회 상품권 text -> json
    '        '상품권 사용처리
    '        If RTN_CD = "0000" Then
    '            Set pCmd = Server.CreateObject("ADODB.Command")
    '                With pCmd
    '                    .ActiveConnection = dbconn
    '                    .NamedParameters = True
    '                    .CommandType = adCmdStoredProc
    '                    .CommandText = "bp_giftcard_status"
	'
    '                    .Parameters.Append .CreateParameter("@mode", adVarChar, adParamInput,30,"giftcard_use")
    '                    .Parameters.Append .CreateParameter("@order_num", adVarChar, adParamInput,100,order_num)
    '                    .Parameters.Append .CreateParameter("@giftcard_number", adVarChar, adParamInput,100,giftcard_serial)
    '                    .Parameters.Append .CreateParameter("@u_cd_brand", adVarChar, adParamInput,10,U_CD_BRAND)
    '                    .Parameters.Append .CreateParameter("@u_cd_partner", adVarChar, adParamInput,50,U_CD_PARTNER)
    '                    .Parameters.Append .CreateParameter("@ok_num", adVarChar, adParamInput,50,OK_NUM)
    '                    .Execute
    '                End With
    '            Set pCmd = Nothing
    '        Else
            %>
            <!--<script type="text/javascript">
                alert("상품권 사용에 실패하였습니다.");
                location.href = "/";
            </script>-->
             <%
    '            'Response.Write "{""result"":99, ""result_msg"":"""& RTN_MSG &"""}"
    '            Response.End
    '        End If
    '        '상품권 사용처리
    '        '쿠키 제거
    '        Response.Cookies("giftcard_serial") = ""
    '        Response.Cookies("brand_code") = ""
    '        '쿠키 제거
    '    Else
        %>
            <!--<script type="text/javascript">
                alert("상품권 사용에 실패하였습니다.");
                location.href = "/";
            </script>-->
             <%
    '        'Response.Write "{""result"":99, ""result_msg"":""상품권 사용에 실패하였습니다.""}"
    '        Response.End
    '    End If
    'End If		
	' 2021-07 더페이 상품권 주석 처리 끝 
		
	'' 2021-07 더페이 상품권 복수처리 시작  
	'dim jsonGiftcard : jsonGiftcard = ""
	'dim arrGiftcard : arrGiftcard = split(giftcard_serial, "||") ' 상품권 번호 
	'dim arrGiftcardAmt : arrGiftcardAmt = split(giftcard_serial, "||") ' 상품권 금액  		 
	'dim chkStat : chkStat = ""
	'  
	''Response.Write "Ubound / // " & Ubound(arrGiftcard) & "<BR>"
	'For i = 0 To Ubound(arrGiftcard)
	'	'giftcard_serial   = arrGiftcard(i) 
	'	arrGiftcardAmt(i) = 0
	'			  
	'	If arrGiftcard(i) <> "" Then 
	'		If jsonGiftcard = "" Then
	'			jsonGiftcard = "{ ""SRV"":""HOMEPAGE"",""GIFTCARD"":["
	'            jsonGiftcard = jsonGiftcard & "{""SN"":""" & arrGiftcard(i) & """}"
	'		Else
	'			jsonGiftcard = jsonGiftcard & ",{""SN"":""" & arrGiftcard(i) & """}"
	'		End If  				 
	'		'Response.Write "jsonGiftcard / " & i & " // " & jsonGiftcard & "<BR>"
	'	End If
	'Next


	'sonGiftcard <> "" Then
	'	
	'jsonGiftcard = jsonGiftcard & "]}"				  
	''Response.Write "jsonGiftcard /// " & jsonGiftcard & "<BR>"

	'' 상품권 조회
	'Set httpRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
	'httpRequest.Open "POST", "https://api-2.bbq.co.kr/api/VoucherInfo/", False
	'httpRequest.SetRequestHeader "Authorization", "BF84B3C90590"  
	'httpRequest.SetRequestHeader "Content-Type", "application/json"
    'httpRequest.Send jsonGiftcard 
	''상품권 조회
	''조회 상품권 text -> json
	'Set oJSON = New aspJSON
	''Response.Write "list /// " & httpRequest.responseText & "<BR>"
	'postResponse = "{""list"" : " & httpRequest.responseText & "}"
	'oJSON.loadJSON(postResponse)
	'Set this = oJSON.data("list")
	''U_CD_BRAND = brand_code '사용브랜드코드
	''U_CD_PARTNER = branch_id ' 사용매장코드
	'MA_RTN_CD  = this.item("Voucher_INFO").item("MA_RTN_CD") '  
	'MA_RTN_MSG = this.item("Voucher_INFO").item("MA_RTN_MSG") ' 사용여부
	''조회 상품권 text -> json				 
	''Response.Write "MA_RTN_CD /// " & MA_RTN_CD & "<BR>"
	''Response.Write "MA_RTN_MSG /// " & MA_RTN_MSG & "<BR>"
	'		 				 
	'Sql = " INSERT INTO bt_giftcard_log(source_id, order_num, giftcard_no, api_nm, in_param, out_param, MA_RTN_CD, MA_RTN_MSG, 'regdate) "_
	'	& " VALUES ( '\pay\ktr\Coupon_Return.asp', '"& order_num &"','"& giftcard_serial &"','https://api-2.bbq.co.kr/api/VoucherInfo/', '"& jsonGiftcard &"','"& postResponse &"','"& MA_RTN_CD &"','"& MA_RTN_MSG &"', GETDATE() ) "
	'dbconn.Execute(Sql)

	'If MA_RTN_CD = "0000" Then 				 
	'	'Response.Write "SN  /// " & Ubound(this.data("Voucher_INFO").data("data").item("SN")) & "<BR>"
	'	For Each row In this.item("Voucher_INFO").item("data")
	'		Set this1 = this.item("Voucher_INFO").item("data").item(row) 
	'		arrGiftcard(row)    = this1.item("SN")
	'		arrGiftcardAmt(row) = this1.item("AMT")				  
	'	Next

	'	jsonGiftcard = ""
	'	For i = 0 To Ubound(arrGiftcard) 				  
	'		If arrGiftcard(i)  <> "" Then 
	'			If jsonGiftcard = "" Then
	'				jsonGiftcard = "{ ""U_CD_BRAND"":""" & brand_code & """," _
	'		                        & """U_CD_PARTNER"":""" & branch_id & """," _
	'		                        & """ORDER_ID"":""" & order_num & """," _
	'		                        & """SRV"":""HOMEPAGE""," _
	'		                        & """GIFTCARD"":["				                   
	'				jsonGiftcard = jsonGiftcard & "{""SN"":""" & arrGiftcard(i)  & """, ""AMT"":""" & arrGiftcardAmt(i) & """}"
	'			Else
	'				jsonGiftcard = jsonGiftcard & ",{""SN"":""" & arrGiftcard(i)  & """, ""AMT"":""" & arrGiftcardAmt(i) & """}"
	'			End If   				 
	'			'Response.Write "jsonGiftcard / " & i & " // " & jsonGiftcard & "<BR>"
	'		End If
	'	Next
	'		 
	'	If jsonGiftcard <> "" Then 
	'		jsonGiftcard = jsonGiftcard & "]}" 
	'		'Response.Write "jsonGiftcard /// " & jsonGiftcard & "<BR>"

	'		' 상품권 사용
	'		Set httpRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
	'		httpRequest.Open "POST", "https://api-2.bbq.co.kr/api/VoucherUse/", False
	'		httpRequest.SetRequestHeader "Authorization", "BF84B3C90590"  
	'		httpRequest.SetRequestHeader "Content-Type", "application/json"
	'		httpRequest.Send jsonGiftcard 
	'		'상품권 사용
	'		 
	'	    '사용 상품권 text -> json
	'	    Set gJSON = New aspJSON
	'	    gpostResponse = "{""list"" : " & httpRequest.responseText & "}" 				 
	'		'Response.Write "list /// " & httpRequest.responseText & "<BR>" 
	'	    gJSON.loadJSON(gpostResponse)
	'	    Set this = gJSON.data("list") 
	'		 
	'		MA_RTN_CD  = this.item("Voucher_Use").item("MA_RTN_CD") '  
	'		MA_RTN_MSG = this.item("Voucher_Use").item("MA_RTN_MSG") ' 사용여부
	'		'사용 상품권 text -> json				 
	'		'Response.Write "Use MA_RTN_CD /// " & MA_RTN_CD & "<BR>"
	'		'Response.Write "Use MA_RTN_MSG /// " & MA_RTN_MSG & "<BR>"			
	'		  
	'		Sql = " INSERT INTO bt_giftcard_log(source_id, order_num, giftcard_no, api_nm, in_param, out_param, MA_RTN_CD, MA_RTN_MSG, regdate) "_
	'		    & " VALUES ( '\pay\ktr\Coupon_Return.asp', '"& order_num &"','"& giftcard_serial &"','https://api-2.bbq.co.kr/api/VoucherUse/', '"& jsonGiftcard &"','"& gpostResponse &"','"& MA_RTN_CD &"','"& MA_RTN_MSG &"', GETDATE() ) "
	'		dbconn.Execute(Sql)
	'		  
	'		If MA_RTN_CD = "0000" THEN 				 
	'			'Response.Write "SN  /// " & Ubound(this.data("Voucher_INFO").data("data").item("SN")) & "<BR>"
	'			For Each row In this.item("Voucher_Use").item("data")
	'				Set this1 = this.item("Voucher_Use").item("data").item(row)
  
	'		        Set pCmd = Server.CreateObject("ADODB.Command")
	'		            With pCmd
	'		                .ActiveConnection = dbconn
	'		                .NamedParameters = True
	'		                .CommandType = adCmdStoredProc
	'		                .CommandText = "bp_giftcard_status"
	'		
	'		                .Parameters.Append .CreateParameter("@mode"           , adVarChar, adParamInput, 30,"giftcard_use"       )
	'		                .Parameters.Append .CreateParameter("@order_num"      , adVarChar, adParamInput,100, order_num           )
	'		                .Parameters.Append .CreateParameter("@giftcard_number", adVarChar, adParamInput,100, this1.item("SN")    )
	'		                .Parameters.Append .CreateParameter("@u_cd_brand"     , adVarChar, adParamInput, 10 ,brand_code          )
	'		                .Parameters.Append .CreateParameter("@u_cd_partner"   , adVarChar, adParamInput, 50, branch_id           )
	'		                .Parameters.Append .CreateParameter("@ok_num"         , adVarChar, adParamInput, 50, this1.item("OK_NUM"))
	'		                .Execute
	'		            End With
	'		        Set pCmd = Nothing
	'		  
	'			Next
	'		  
	'		Else   ' If MA_RTN_CD = "0000" THEN 
					%>
					<!--<script type="text/javascript">
						alert("상품권 사용에 실패하였습니다.");
						location.href = "/";
					</script>-->
						<%
					'Response.Write "{""result"":99, ""result_msg"":"""& RTN_MSG &"""}"
	'				Response.End

	'			End If ' If MA_RTN_CD = "0000" THEN  

	'		End If  ' If jsonGiftcard <> "" Then
							  

	'	    '쿠키 제거
	'	    Response.Cookies("giftcard_serial") = ""
	'	    Response.Cookies("brand_code") = ""
	'	    '쿠키 제거

	'	Else   ' If MA_RTN_CD = "0000" THEN 
			%>
			<!--<script type="text/javascript">
                alert("상품권 사용에 실패하였습니다.");
                location.href = "/";
            </script>-->
				<%
			'Response.Write "{""result"":99, ""result_msg"":"""& RTN_MSG &"""}"
	'		Response.End

	'	End If   ' If MA_RTN_CD = "0000" THEN    
					  
	'End If  ' If jsonGiftcard <> "" Then 
	'' 2021-07 더페이 상품권 복수처리 끝 

	Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','['+convert(varchar(19), getdate() , 120) + '] "& order_channel &"','0','Coupon_Return-000')"
	dbconn.Execute(Sql)
	
	'지류상품권 사용 처리 inc_giftcard_use.asp (2021. 10 더페이)
	'inc_giftcard_use.asp에서 order_num, order_idx, brand_code, branch_id 사용함
										 
%>
<!--#include virtual="/order/inc_giftcard_use.asp"-->

<%
	If order_type = "D" Then
		order_type_title = "배달정보"
		order_type_name = "배달매장"
		address_title = "배달주소"
		address = ""
	ElseIf order_type = "P" Then
		order_type_title = "포장정보"
		order_type_name = "포장매장"
		address_title = "포장매장주소"
		address = ""
	End If

	Select Case pay_type
		Case "Card"
		pay_type_title = "온라인결제"
		pay_type_name = "신용카드"
		payMethodCode = "23"
		Case "Phone"
		pay_type_title = "온라인결제"
		pay_type_name = "휴대전화 결제"
		payMethodCode = "24"
		Case "Point"
		pay_type_title = "온라인결제"
		pay_type_name = "포인트"
		payMethodCode = "99"
		Case "Later"
		pay_type_title = "현장결제"
		pay_type_name = "신용카드"
		payMethodCode = "23"
		Case "Cash"
		pay_type_title = "현장결제"
		pay_type_name = "현금"
		payMethodCode = "21"
		Case "Payco"
		pay_type_title = "페이코"
		pay_type_name = "간편결제"
		payMethodCode = "31"
		Case "Paycoin"
		pay_type_title = "페이코인"
		pay_type_name = "간편결제"
		payMethodCode = "41"
		Case "Sgpay"
		pay_type_title = "BBQ PAY"
		pay_type_name = "간편결제"
		payMethodCode = "42"
		Case "Sgpay2"
		pay_type_title = "BBQ PAY"
		pay_type_name = "간편결제"
		payMethodCode = "42"
		Case "ECoupon"
		pay_type_title = "E 쿠폰"
		pay_type_name = "E 쿠폰"
		payMethodCode = "99"
		Case else
		pay_type_title = "기타"
		pay_type_name = "기타"
		payMethodCode = "99"
	End Select

	Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','['+convert(varchar(19), getdate() , 120) + '] "& member_type & "/" & order_channel &"','0','Coupon_Return-001')"
	dbconn.Execute(Sql)

    ' 주문내에 e쿠폰 사용여부 체크 ##################
	Dim CouponUseCheck : CouponUseCheck = "N"

	Set orderCmd = Server.CreateObject("ADODB.Command")
	With orderCmd
		.ActiveConnection = dbconn
		.NamedParameters = True
		.CommandType = adCmdStoredProc
		.CommandText = "bp_order_detail_select"
		.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput, , order_idx)

		Set orderRs = .Execute
	End With
	Set orderCmd = Nothing

	If Not (orderRs.BOF Or orderRs.EOF) Then
		sCouponPin = orderRs("coupon_pin")
		prefix_coupon_no = LEFT(sCouponPin, 1)
		If prefix_coupon_no = "6" or prefix_coupon_no = "8" Then		'COOP coupon prefix 
			eCouponType = "Coop"
			cl_eCouponCoop.Coop_Check_Order_Coupon order_idx, dbconn

			if cl_eCouponCoop.m_cd = "0" then
				CouponUseCheck = "N"
			else
				CouponUseCheck = "Y"
			end if			
		Else 
			eCouponType = "KTR"
			cl_eCoupon.KTR_Check_Order_Coupon order_idx, dbconn
			
			if cl_eCoupon.m_cd = "0" then
				CouponUseCheck = "N"
			else
				CouponUseCheck = "Y"
			end if
		End If
		
		Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','['+convert(varchar(19), getdate() , 120) + '] "& sCouponPin & "/" & CouponUseCheck &"','0','Coupon_Return-002')"
		dbconn.Execute(Sql)
	End If
	Set orderRs = nothing 

	'response.write cl_eCouponCoop.m_cd &"-"& CouponUseCheck
	'response.end

    If CouponUseCheck = "Y" Then 
%>
                <script type="text/javascript">

                    alert("이미 사용된 쿠폰이 존재합니다. 다시 확인하시기 바랍니다.");

					opener.clearCart();
                    opener.location.href = "/";
                    window.close();
                </script>
<%
        Response.End 
    End If 


	If member_type = "Member" Then
		Sql = "Select payco_log, coupon_amt From bt_order_payco Where order_idx="& order_idx
		Set Pinfo = dbconn.Execute(Sql)
		If Not Pinfo.eof Then 
			payco_log = Pinfo("payco_log")
			coupon_amt = Pinfo("coupon_amt")

			Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"','"& coupon_amt &"','Coupon_Return-1')"
			dbconn.Execute(Sql)

			Set resC = OrderUseListForOrder(payco_log)
			If resC.mMessage = "SUCCESS" Then

				Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"','"& coupon_amt &"','Coupon_Return-2')"
				dbconn.Execute(Sql)

				'pay_detail 생성
				'카드별 사용 포인트 추가
				For i = 0 To UBound(resC.mPointUseList)
					If resC.mPointUseList(i).mUsePoint > 0 Then
						db_call.DB_Payment_Insert order_idx, "PAYCOPOINT", resC.mCode, resC.mPointUseList(i).mAccountTypeCode, resC.mPointUseList(i).mCardNo, resC.mPointUseList(i).mUsePoint, "", resC.mCode, resC.mMessage, JSON.stringify(payco_log)
					End If
				Next

				Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"','"& coupon_amt &"','Coupon_Return-3')"
				dbconn.Execute(Sql)

				'Response.write JSON.stringify(reqC.toJson())
				If coupon_amt > 0 Then
					db_call.DB_Payment_Insert order_idx, "PAYCOCOUPON", resC.mCode, "", "", coupon_amt, "", resC.mCode, resC.mMessage, JSON.stringify(payco_log)
				End If 

				Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"','"& coupon_amt &"','Coupon_Return-4')"
				dbconn.Execute(Sql)

			Else

				Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") & CanCelURL &"','"& coupon_amt &"','Coupon_Return-5')"
				dbconn.Execute(Sql)
%>
				<script type="text/javascript">
					alert("멤버십 처리 도중 오류가 발생했습니다.");
					opener.location.href = "/";
					window.close();
				</script>
<%
				Response.End

			End If
		End If 
		Set Pinfo = Nothing
	End If 

	Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"','"& coupon_amt &"','Coupon_Return-6')"
	dbconn.Execute(Sql)

	'E 쿠폰처리 bt_order_detail 에 쿠폰 사용내역이 있다면 결제정보에 추가 함
'    response.write "order_num : " & order_num & "<BR>"
	Set pinCmd = Server.CreateObject("ADODB.Command")
	with pinCmd
		.ActiveConnection = dbconn
		.CommandText = "bp_order_detail_select_ecoupon"
		.CommandType = adCmdStoredProc

		.Parameters.Append .CreateParameter("@ORDER_IDX", adInteger, adParamInput, , order_idx)
		Set pinRs = .Execute
	End With
	Set pinCmd = Nothing

	Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"','"& coupon_amt &"','Coupon_Return-7')"
	dbconn.Execute(Sql)

	If pinRs.Eof And pinRs.Bof Then
	Else

		Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"','"& coupon_amt &"','Coupon_Return-8')"
		dbconn.Execute(Sql)

		'***** pay insert
		Set aCmd = Server.CreateObject("ADODB.Command")
		With aCmd
			.ActiveConnection = dbconn
			.NamedParameters = True
			.CommandType = adCmdStoredProc
			.CommandText = "bp_order_payment_select"

			.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput, , order_idx)

			Set aRs = .Execute
		End With
		Set aCmd = Nothing

		Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"','"& coupon_amt &"','Coupon_Return-9')"
		dbconn.Execute(Sql)

		'연결된 pay가 있는지 확인'
		If Not (aRs.BOF Or aRs.EOF) Then

		Else
			'없으면 pay_idx 생성'
			Set aCmd = Server.CreateObject("ADODB.Command")
			With aCmd
				.ActiveConnection = dbconn
				.NamedParameters = True
				.CommandType = adCmdStoredProc
				.CommandText = "bp_payment_insert"

				.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput,,order_idx)
				.Parameters.Append .CreateParameter("@member_idx", adInteger, adParamInput, , member_idx)
				.Parameters.Append .CreateParameter("@member_idno", adVarChar, adParamInput, 50, member_idno)
				.Parameters.Append .CreateParameter("@member_type", adVarChar, adParamInput, 10, member_type)
				.Parameters.Append .CreateParameter("@pay_amt", adCurrency, adParamInput,, pay_amt)
				.Parameters.Append .CreateParameter("@pay_status", adVarChar, adParamInput, 10, "P")

				.Parameters.Append .CreateParameter("@ERRCODE", adInteger, adParamOutput)
				.Parameters.Append .CreateParameter("@ERRMSG", adVarChar, adParamOutput, 500)

				.Execute

				errCode = .Parameters("@ERRCODE").Value
				errMsg = .Parameters("@ERRMSG").Value
			End With
			Set aCmd = Nothing

			Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"/"& errCode &"/"& errMsg &"','"& coupon_amt &"','Coupon_Return-10')"
			dbconn.Execute(Sql)

		End If
		Set aRs = Nothing

		Do Until pinRs.EOF
			Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"','"& coupon_amt &"','Coupon_Return-11')"
			dbconn.Execute(Sql)

			prefix_coupon_no = LEFT(pinRs("coupon_pin"), 1)
			If prefix_coupon_no = "6" or prefix_coupon_no = "8" Then
				eCouponType = "Coop"
			else 
				eCouponType = "KTR"
			end if 

			if eCouponType = "Coop" then
				cl_eCouponCoop.Coop_Use_Pin pinRs("coupon_pin"), order_num, branch_id, branch_name, dbconn
			else 
				cl_eCoupon.KTR_Use_Pin pinRs("coupon_pin"), order_num, branch_id, branch_name, dbconn
			end if 

			Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"/"& Replace(pinRs("coupon_pin"),"'","") &"','"& coupon_amt &"','Coupon_Return-12')"
			dbconn.Execute(Sql)

			if eCouponType = "Coop" then
				if cl_eCouponCoop.m_cd = "0" then
					db_call.DB_Payment_Insert order_idx, "ECOUPON", pinRs("coupon_pin"), "", "", pinRs("menu_price"), "", 0, "", ""

					' 마이 쿠폰사용
					Sql = "update bt_member_coupon set use_yn='Y', last_use_date=getdate(), order_idx='"& order_idx &"' where c_code='"& pinRs("coupon_pin") &"' "
					dbconn.Execute(Sql)

					Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"/"& Replace(pinRs("coupon_pin"),"'","") &"','"& coupon_amt &"','Coupon_Return-13')"
					dbconn.Execute(Sql)
				else
					pg_RollBack = 1
					exit do
				end if
			else 
				if cl_eCoupon.m_cd = "0" then
					db_call.DB_Payment_Insert order_idx, "ECOUPON", pinRs("coupon_pin"), "", "", pinRs("menu_price"), "", 0, "", ""

					' 마이 쿠폰사용
					Sql = "update bt_member_coupon set use_yn='Y', last_use_date=getdate(), order_idx='"& order_idx &"' where c_code='"& pinRs("coupon_pin") &"' "
					dbconn.Execute(Sql)

					Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"/"& Replace(pinRs("coupon_pin"),"'","") &"','"& coupon_amt &"','Coupon_Return-13')"
					dbconn.Execute(Sql)
				else
					pg_RollBack = 1
					exit do
				end if
			end if
			pinRs.MoveNext
		Loop
	End If	
	Set pinRs = Nothing 

	Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"','"& coupon_amt &"','Coupon_Return-14')"
	dbconn.Execute(Sql)

	if pg_RollBack = 1 then
		if eCouponType = "Coop" then
			cl_eCouponCoop.Coop_Rollback order_idx, dbconn
		else 
			cl_eCoupon.KTR_Rollback order_idx, dbconn
		end if 
			' 마이 쿠폰 취소
			Sql = "update bt_member_coupon set use_yn='N' where order_idx='"& order_idx &"' "
			dbconn.Execute(Sql)
%>
				<script type="text/javascript">
					alert("이미 사용된 쿠폰이 존재합니다!!");

					opener.clearCart();
					opener.location.href = "/";
					window.close();
				</script>
<%
		Response.End
	end if

	Set aCmd = Server.CreateObject("ADODB.Command")
	With aCmd
		.ActiveConnection = dbconn
		.NamedParameters = True
		.CommandType = adCmdStoredProc
		.CommandText = "bp_bbq_order"

		.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput, , order_idx)

		.Execute
	End With
	Set aCmd = Nothing

	Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('"& order_idx &"','"& Replace(payco_log,"'","") &"','"& coupon_amt &"','Coupon_Return-15')"
	dbconn.Execute(Sql)

	'====================================포인트 이벤트 2019-04-30 까지 진행
	PAYCOUPON_USEYN = "N"
	EVENTPOINT_PRODUCTCD = ""
	EVENT_POINT = 0
	If Date <= "2019-05-20" Then
		Set aCmd = Server.CreateObject("ADODB.Command")
		With aCmd
			.ActiveConnection = dbconn
			.NamedParameters = True
			.CommandType = adCmdStoredProc
			.CommandText = "bp_event_point_uselist"

			.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput, , order_idx)

			Set aRs = .Execute
		End With
		Set aCmd = Nothing

		If Not (aRs.BOF Or aRs.EOF) Then
			aRs.MoveFirst
			Do until aRs.EOF
				EVT_PAYMETHOD	= aRs("pay_method")
				EVT_PRODUCTCD	= aRs("pay_transaction_id")

				If EVT_PAYMETHOD = "EVENTPOINT" Then 
					EVENTPOINT_PRODUCTCD = EVT_PRODUCTCD
					EVENT_POINT = 4000
				ElseIf EVT_PAYMETHOD = "PAYCOCOUPON" Then 
					PAYCOUPON_USEYN = "Y"
				End If 
				aRs.MoveNext
			Loop
		End If
		Set aRs = Nothing
	End If 

	Temp_EVENT_POINT = EVENT_POINT
	'====================================포인트 이벤트 2019-04-30 까지 진행

	Dim reqOC : Set reqOC = New clsReqOrderComplete
	reqOC.mCompanyCode = PAYCO_MEMBERSHIP_COMPANYCODE
	reqOC.mMerchantCode = branch_id
'    reqOC.mMerchantCode = PAYCO_MERCHANTCODE
	reqOC.mMemberNo = member_idno
	reqOC.mServiceTradeNo = order_num
	'reqOC.mOrderYmdt = dd&" "&dt
	
	If PAYCOUPON_USEYN = "Y" Then	'포인트이벤트에서 쿠폰사용시 적립안함
		reqOC.mSaveYn = "N"
	Else
		reqOC.mSaveYn = "Y"
	End If 

	reqOC.mDeliveryCharge = delivery_fee
	reqOC.mOrderChannel = order_channel

	Set aCmd = Server.CreateObject("ADODB.Command")
	With aCmd
		.ActiveConnection = dbconn
		.NamedParameters = True
		.CommandType = adCmdStoredProc
		.CommandText = "bp_order_detail_select"

		.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput, , order_idx)

		Set aRs = .Execute
	End With
	Set aCmd = Nothing

	Set OItem = New clsOuterPayMethodList
	OItem.mCode = payMethodCode
	OItem.mPayAmount = pay_amt
	OItem.mApprovalNo = ""
	OItem.mApprovalYmdt = ""
	reqOC.addOuterPayMethodList(OItem)

	If Not (aRs.BOF Or aRs.EOF) Then
		aRs.MoveFirst
		Do until aRs.EOF
			Order_qty = aRs("menu_qty")
			Temp_Order_Qty = Order_qty

			If Temp_EVENT_POINT > 0 And ""&EVENTPOINT_PRODUCTCD = ""&aRs("menu_idx") Then '이벤트 포인트 사용한 경우
				Set pItem = New clsProductList
				If aRs("upper_order_detail_idx") = 0 Then
					pItem.mProductClassCd = "M"
					pItem.mProductClassNm = "메인"
				Else
					pItem.mProductClassCd = "S"
					pItem.mProductClassNm = "사이드"
				End If
				pItem.mProductCd = aRs("poscode")'aRs("menu_idx")'
				pItem.mProductNm = aRs("menu_name")
				pItem.mUnitPrice = aRs("menu_price") - Temp_EVENT_POINT
				pItem.mTargetUnitPrice = aRs("menu_price") - Temp_EVENT_POINT
				pItem.mProductCount = 1
				If Len(aRs("coupon_pin")) > 0 Then	'E 쿠폰 적립 제외
					pItem.mProductSaveYn = "N"
				else
					pItem.mProductSaveYn = "Y"
				End If 

				reqOC.addProductList(pItem)

				Temp_Order_Qty = Temp_Order_Qty - 1
				Temp_EVENT_POINT = 0

			End If 
			If Temp_Order_Qty > 0 Then 
				Set pItem = New clsProductList
				If aRs("upper_order_detail_idx") = 0 Then
					pItem.mProductClassCd = "M"
					pItem.mProductClassNm = "메인"
				Else
					pItem.mProductClassCd = "S"
					pItem.mProductClassNm = "사이드"
				End If
				pItem.mProductCd = aRs("poscode")'aRs("menu_idx")'
				pItem.mProductNm = aRs("menu_name")
				pItem.mUnitPrice = aRs("menu_price")
				pItem.mTargetUnitPrice = aRs("menu_price")
				pItem.mProductCount = Temp_Order_Qty
				If Len(aRs("coupon_pin")) > 0 Then	'E 쿠폰 적립 제외
					pItem.mProductSaveYn = "N"
				else
					pItem.mProductSaveYn = "Y"
				End If 

				reqOC.addProductList(pItem)
			End If 
			aRs.MoveNext
		Loop
	End If
	Set aRs = Nothing

	If member_type = "Member" Then
		SAMSUNG_EVENT = Session("SAMSUNG_EVENT")
		If SAMSUNG_EVENT = "Y" Then		'삼성이벤트는 페이코 전문 안보냄
			Session("SAMSUNG_EVENT") = ""
		Else 
			Dim resOC : Set resOC = OrderComplete(reqOC.toJson())
			Response.write "<!--complete "&resOC.mMessage&"||"&JSON.stringify(reqOC.toJson())&"-->"

			If resOC.mMessage = "SUCCESS" Then
				Set aCmd = Server.CreateObject("ADODB.Command")
				With aCmd
					.ActiveConnection = dbconn
					.NamedParameters = True
					.CommandType = adCmdStoredProc
					.CommandText = "bp_order_update_payco"

					.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput, , order_idx)
					.Parameters.Append .CreateParameter("@payco_orderno", adVarChar, adParamInput, 50, resOC.mOrderNo)
					.Parameters.Append .CreateParameter("@ERRCODE", adInteger, adParamOutput)
					.Parameters.Append .CreateParameter("@ERRMSG", adVarChar, adParamOutput, 500)

					.Execute

					errCode = .Parameters("@ERRCODE").Value
					errMsg = .Parameters("@ERRMSG").Value
				End With
				Set aCmd = Nothing
			End If
		End If 

		'포인트 이벤트 때문에 생성	
		If discount_amt > 0 Then	'이안에 이벤트 포인트 할인도 포함이 되어있어서 조건으로 사용 
			Set aCmd = Server.CreateObject("ADODB.Command")
			With aCmd
				.ActiveConnection = dbconn
				.NamedParameters = True
				.CommandType = adCmdStoredProc
				.CommandText = "bp_event_point_paymentyn"

				.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput, , order_idx)
				.Parameters.Append .CreateParameter("@member_idx", adInteger, adParamInput, , member_idx)
				.Parameters.Append .CreateParameter("@ERRCODE", adInteger, adParamOutput)

				.Execute

				errCode = .Parameters("@ERRCODE").Value
			End With
			Set aCmd = Nothing
		End If 
	End If

	'TODO 운영 또는 스테이징 반영시 사용처리
	'TESTMODE = "Y"
	If TESTMODE <> "Y" Then
		If Session("userName") <> "" Then 
			USERNAME = Session("userName")
		Else
			USERNAME = Right(delivery_mobile,4)
		End If 
		TP	= "AT" '알림톡
		CD	= "bizp_2019032115454613182471344"
		PARAM = "고객="& USERNAME &"|메뉴="& MENU_NAME & "|매장명="& branch_name	'[고객이름/번호]
		DEST_PHONE = delivery_mobile	'고객 전화번호
		SEND_PHONE = "15889282"

		Set aCmd = Server.CreateObject("ADODB.Command")
		With aCmd
			.ActiveConnection = dbconn
			.NamedParameters = True
			.CommandType = adCmdStoredProc
			.CommandText = "GNSIS_SMS.GNSIS_SMS.DBO.PRC_SET_SMS_WEB_V2"

			.Parameters.Append .CreateParameter("@TP", adVarChar, adParamInput, 10, TP)
			.Parameters.Append .CreateParameter("@CD", adVarChar, adParamInput, 40, CD)
			.Parameters.Append .CreateParameter("@PARAM", adVarChar, adParamInput, 4000, PARAM)
			.Parameters.Append .CreateParameter("@DEST_PHONE", adVarChar, adParamInput, 20, DEST_PHONE)
			.Parameters.Append .CreateParameter("@SEND_PHONE", adVarChar, adParamInput, 20, SEND_PHONE)
			.Parameters.Append .CreateParameter("@RET", adVarChar, adParamOutput, 4)

			.Execute
			RET = .Parameters("@RET").value
		End With
		Set aCmd = Nothing

		Sql = "	INSERT INTO TB_WEB_ORDER_SEND_MSG_LOG(ORDER_ID, ORDER_STATE, TARGET, DEST_PHONE, CD, SEND_MSG, SEND_RESULT, SEND_DTS)	" & _
			"	VALUES('"& order_num &"', 'P', 'M', '"& DEST_PHONE &"', '"& CD &"', '"& PARAM &"', '"& RET &"', GETDATE())	"
		dbconn.Execute(Sql)

		CD	= "bizp_2019031516533411385566079"
		PARAM = "고객전화번호="& delivery_mobile		'[고객전화번호]
		DEST_PHONE = branch_phone	'매장 전화번호

		Set aCmd = Server.CreateObject("ADODB.Command")
		With aCmd
			.ActiveConnection = dbconn
			.NamedParameters = True
			.CommandType = adCmdStoredProc
			.CommandText = "GNSIS_SMS.GNSIS_SMS.DBO.PRC_SET_SMS_WEB_V2"

			.Parameters.Append .CreateParameter("@TP", adVarChar, adParamInput, 10, TP)
			.Parameters.Append .CreateParameter("@CD", adVarChar, adParamInput, 40, CD)
			.Parameters.Append .CreateParameter("@PARAM", adVarChar, adParamInput, 4000, PARAM)
			.Parameters.Append .CreateParameter("@DEST_PHONE", adVarChar, adParamInput, 20, DEST_PHONE)
			.Parameters.Append .CreateParameter("@SEND_PHONE", adVarChar, adParamInput, 20, SEND_PHONE)
			.Parameters.Append .CreateParameter("@RET", adVarChar, adParamOutput, 4)

			.Execute
			RET = .Parameters("@RET").value
		End With
		Set aCmd = Nothing

		Sql = "	INSERT INTO TB_WEB_ORDER_SEND_MSG_LOG(ORDER_ID, ORDER_STATE, TARGET, DEST_PHONE, CD, SEND_MSG, SEND_RESULT, SEND_DTS)	" & _
			"	VALUES('"& order_num &"', 'P', 'P', '"& DEST_PHONE &"', '"& CD &"', '"& PARAM &"', '"& RET &"', GETDATE())	"
		dbconn.Execute(Sql)
	End If 
	
	'암호화 order_idx (2022.04.28)
	eorder_idx = AESEncrypt(cstr(order_idx))
%>
<script type="text/javascript">
	//alert("주문이 정상적으로 완료되었습니다.");
	opener.location.href = "/order/orderComplete.asp?order_idx=<%=eorder_idx%>&pm=Phone";
	window.close();
</script>
