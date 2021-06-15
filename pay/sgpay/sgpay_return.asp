<!--#include file="sgpay.inc.asp"-->
<!--#include virtual="/pay/coupon_use.asp"-->
<!--#include virtual="/pay/coupon_use_coop.asp"-->
<%
	'-----------------------------------------------------------------------------
	' 이 문서는 text/html 형태의 데이터를 반환합니다.
	'-----------------------------------------------------------------------------
	Response.ContentType = "text/html"

	Dim order_idx
	order_idx = Request("order_idx")

	'-----------------------------------------------------------------------------
	' (로그) 호출 시점과 호출값을 파일에 기록합니다.
	'-----------------------------------------------------------------------------
	Dim xQuery, receive_str
	receive_str = "sgpay_return.asp is Called - "
	receive_str = receive_str &  "POST DATA : "
	For Each xQuery In Request.Form
		receive_str = receive_str &  CStr(xQuery) & " : " & request(xQuery) & ", "
	Next
	receive_str = receive_str &  "GET DATA : "
	For Each xQuery In Request.QueryString
		receive_str = receive_str &  CStr(xQuery) & " : " & request(xQuery) & ", "
	Next
	Call Write_Log(receive_str)


	'-----------------------------------------------------------------------------
	' 오류가 발생했는지 기억할 변수와 결과를 담을 변수를 선언합니다.
	'-----------------------------------------------------------------------------
	Dim doApproval, resultValue
	Dim Read_code, Read_message
	Dim certify_reserveOrderNo, certify_paymentCertifyToken
	Dim returnUrlParam, returnUrlParam1, returnUrlParam2, returnUrlParam3

	doApproval = false											'기본적으로 승인을 받지 않는것으로 설정


	requestToken = Request("token")
	'Response.Write requestToken & "<br />"
	If requestToken = "" Then
		resultMsg = "결제 결과 수신 실패"
		Response.Write resultMsg
		Call Write_Log("sgpay_return.asp is canceled : " & CStr(resultMsg))
		Response.End
	End If

	Call Write_Log("sgpay_return.asp / SGPAY token : " & CStr(requestToken))

	'---------------------------------------------------------------------------------
	' 주문 예약 함수 호출 ( JSON 데이터를 String 형태로 전달 )
	'---------------------------------------------------------------------------------
	decryptedToken = Com.decrypt(requestToken, secretkey)
	'Response.Write decryptedToken & "<br />"
	Call Write_Log("sgpay_return.asp / SGPAY token_decrypted : " & CStr(decryptedToken))

	Set readTokenToJson = New aspJSON
	readTokenToJson.loadJSON(decryptedToken)
	Call Write_Log("sgpay_return.asp / Receive Json Data : " & readTokenToJson.JSONoutput())			' 디버그용
	With readTokenToJson
		ret_Merchant = .data("Merchant")
		ret_Amount = .data("Amount")
		ret_PaymentTime = .data("PaymentTime")
		ret_PaymentNo = .data("PaymentNo")
		ret_TxId = .data("TxId")
		ret_TradeNo = .data("TradeNo")

		If ret_PaymentTime = "" Or ret_PaymentNo = "" Or ret_TxId = "" Then
			resultMsg = "취소되었습니다."
			Call Write_Log("sgpay_return.asp is canceled : " & CStr(resultMsg))

			Set resMC = OrderCancelListForOrder(order_idx)

			If resMC.mCode = 0 Then
				sgpayDone = True
			End If
			%>
			<html>
				<head>
					<title>주문 취소</title>
					<script type="text/javascript">
						alert("<%=resultMsg%>");
						<%
							If sgpayDone then
								order_idx = ""
							End If

							If WebMode = "MOBILE" Or Request.ServerVariables("HTTP_HOST") = "m.bbq.co.kr" Or Request.ServerVariables("HTTP_HOST") = "mtest.bbq.co.kr" Or Request.ServerVariables("HTTP_HOST") = "bbq.fuzewire.com:8010" Then
						%>
						location.href = "/order/cart.asp?cancel_idx=<%=order_idx%>";
						<%
							Else
								If Not sgpayDone Then
						%>
						opener.parent.cancelMembership();
						<%
								End If
						%>
						window.close();
						<%
							End If
						%>
					</script>
				</head>
			</html>
			<% 
			Response.End											'페이지 종료
		End If
	End With

	'-----------------------------------------------------------------------------
	' 오류 확인용 변수 선언
	'-----------------------------------------------------------------------------
	Dim RaiseError : RaiseError = False
	Dim ErrMessage

	'처리 결과를 성공으로 가정
	doApproval = True
	ErrMessage = ""
	'On Error Resume Next															'제일 하단 Err.Number 로 오류 체크 하기 위해 사용됩니다.
	'★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
	'★★★★★★★★★★                                                     ★★★★★★★★★★
	'★★★★★★★★★★                    중요 사항                         ★★★★★★★★★★
	'★★★★★★★★★★                                                     ★★★★★★★★★★
	'★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
	'
	' 총 금액 결제된 금액을 주문금액과 비교.(반드시 필요한 검증 부분.)
	' 주문금액을 변조하여 결제를 시도 했는지 확인함.(반드시 DB에서 읽어야 함.)
	' 금액이 변조되었으면 반드시 승인을 취소해야 함.
	'
	'★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
	Dim myDBtotalValue

	'myDBtotalValue = 69000													'DB에서 주문시 주문했던 총 금액(PAYCO 에 주문예약할때 던졌던 값.)을 가져옵니다.(주문값)

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

	Dim shopInfoError
	shopInfoError = false

	If Not (pRs.BOF Or pRs.EOF) Then
		USER_ID = pRs("member_idno")
		MEMBER_IDX = pRs("member_id")
		MEMBER_TYPE = pRs("member_type")

		order_num = pRs("order_num")

		PAYAMOUNT = pRs("order_amt") + pRs("delivery_fee")
		AMOUNT = PAYAMOUNT-pRs("discount_amt")
		branch_id = pRs("branch_id")

		' 매장정보 조회...
		Set aCmd = Server.CreateObject("ADODB.Command")

		With aCmd
			.ActiveConnection = dbconn
			.NamedParameters = True
			.CommandType = adCmdStoredProc
			.CommandText = "bp_branch_select"

			.Parameters.Append .CreateParameter("@branch_id", adInteger, adParamInput, , branch_id)

			Set aRs = .Execute
		End With

		Set aCmd = Nothing

		If Not (aRs.BOF Or aRs.EOF) Then
			vBranchName = aRs("branch_name")
			vBranchTel = aRs("branch_tel")
			vDeliveryFee = aRs("delivery_fee")
			vSubCPID = aRs("DANAL_H_SCPID")
			vUseDANAL = aRs("USE_DANAL")
			vUsePAYCO = aRs("USE_PAYCO")
			vPayco_Seller = aRs("payco_seller")
			vPayco_Cpid = aRs("payco_cpid")
			vPayco_Itemcd = aRs("payco_itemcd")

			If TESTMODE <> "Y" Then
				sellerKey				=	vPayco_Seller'"S0FSJE"									'(필수) 가맹점 코드 - 파트너센터에서 알려주는 값으로, 초기 연동 시 PAYCO에서 쇼핑몰에 값을 전달한다.
				cpId					=	vPayco_Cpid'"PARTNERTEST"								'(필수) 상점ID, 30자 이내
				productId				=	vPayco_Itemcd'"PROD_EASY"									'(필수) 상품ID, 50자 이내
			Else 
				If branch_id = "1146001" Then
					sellerKey				=	vPayco_Seller'"S0FSJE"									'(필수) 가맹점 코드 - 파트너센터에서 알려주는 값으로, 초기 연동 시 PAYCO에서 쇼핑몰에 값을 전달한다.
					cpId					=	vPayco_Cpid'"PARTNERTEST"								'(필수) 상점ID, 30자 이내
					productId				=	vPayco_Itemcd'"PROD_EASY"									'(필수) 상품ID, 50자 이내
				Else
					sellerKey				=	"S0FSJE"									'(필수) 가맹점 코드 - 파트너센터에서 알려주는 값으로, 초기 연동 시 PAYCO에서 쇼핑몰에 값을 전달한다.
					cpId					=	"PARTNERTEST"								'(필수) 상점ID, 30자 이내
					productId				=	"PROD_EASY"									'(필수) 상품ID, 50자 이내
				End If
			End If 
			If vPayco_Seller = "" Then
				shopInfoError = True
				ErrMessage = "매장정보가 잘못되었습니다."

				Set aRs = Nothing
				'response.End
			End If
		Else
			shopInfoError = True
			ErrMessage = "매장정보가 없습니다."

			Set aRs = Nothing
			'response.End
		End If
	Else
		ORDER_NUM = ""
		USER_ID = ""
		MEMBER_IDX = 0
		MEMBER_TYPE = ""
		SUBCPID = ""
		AMOUNT = ""
	End If

	' 제주/산간 =========================================================================================
	Set pCmd = Server.CreateObject("ADODB.Command")
	With pCmd
		.ActiveConnection = dbconn
		.NamedParameters = True
		.CommandType = adCmdStoredProc
		.CommandText = "bp_order_detail_select_1138"

		.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput, , order_idx)

		Set pRs = .Execute
	End With
	Set pCmd = Nothing

	If Not (pRs.BOF Or pRs.EOF) Then
		AMOUNT = AMOUNT + (pRs("menu_price")*pRs("menu_qty"))
	End If
	' =========================================================================================

	Set pRs = Nothing

	' 주문내에 e쿠폰 사용여부 체크 ##################
	dim cl_eCoupon : set cl_eCoupon = new eCoupon
    dim cl_eCouponCoop : set cl_eCouponCoop = new eCouponCoop

	Set pinCmd = Server.CreateObject("ADODB.Command")
	with pinCmd
		.ActiveConnection = dbconn
		.CommandText = "bp_order_detail_select_ecoupon"
		.CommandType = adCmdStoredProc

		.Parameters.Append .CreateParameter("@ORDER_IDX", adInteger, adParamInput, , order_idx)
		Set pinRs = .Execute
	End With
	Set pinCmd = Nothing

	prefix_coupon_no = LEFT(pinRs("coupon_pin"), 1)
	Set pinRs = Nothing

	If prefix_coupon_no = "6" or prefix_coupon_no = "8" Then		'COOP coupon prefix 
		eCouponType = "Coop"
	Else 
		eCouponType = "KTR"
	End If

	Dim CouponUseCheck : CouponUseCheck = "N"

	If eCouponType = "Coop" Then
		cl_eCouponCoop.Coop_Check_Order_Coupon order_idx, dbconn
		if cl_eCouponCoop.m_cd = "0" then
			CouponUseCheck = "N"
		else
			CouponUseCheck = "Y"
		end if
	Else
		cl_eCoupon.KTR_Check_Order_Coupon order_idx, dbconn                  
		if cl_eCoupon.m_cd = "0" then
			CouponUseCheck = "N"
		else
			CouponUseCheck = "Y"
		end if
	End If 


	If (Not CStr(ret_Amount) = CStr(AMOUNT)) or (Not CStr(ret_TradeNo) = CStr(order_num)) Then		'위에서 파라메터로 받은 ret_Amount 값과 주문값이 같은지 비교합니다. 
																			'( 연동 실패를 테스트 하시려면 값을 주문값을 ret_Amount 값과 틀리게 설정하세요. )
		doApproval = false
		RaiseError = true
		ErrMessage = "주문금액(" & CStr(AMOUNT) & ")과 결제금액(" & CStr(ret_Amount) & ")이 틀립니다."
		
	ElseIf CouponUseCheck = "Y" Then 

		doApproval = false
		RaiseError = true
		ErrMessage = "주문내용에 이미 사용된 쿠폰이 있습니다"

	Else
		'-----------------------------------------------------------------------------
		' 결제 승인 성공시 데이터를 수신하여 사용( DB에 저장 )
		' 오류시 승인내역을 조회하여 취소할 수 있도록 RaiseError = False 설정
		'-----------------------------------------------------------------------------
		On Error Resume Next
		If shopInfoError Then
			RaiseError = True
		End If

		'---------------------------------------------------------------------------------
		' DB 저장중 오류가 발생하였으면 오류를 유발시킴
		'---------------------------------------------------------------------------------
		If Not Err.Number = 0 Then
			RaiseError = True
			ErrMessage = Err.Description
		End If
	End If

	If Not RaiseError Then
		Call Write_Log("sgpay_return.asp return success.")

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

		'연결된 pay가 있는지 확인'
		If Not (aRs.BOF Or aRs.EOF) Then
'			pay_idx = aRs("pay_idx")
'			Call Write_Log("pay_idx exist." & pay_idx)
		Else
			'없으면 pay_idx 생성'
			Set aCmd = Server.CreateObject("ADODB.Command")
			With aCmd
				.ActiveConnection = dbconn
				.NamedParameters = True
				.CommandType = adCmdStoredProc
				.CommandText = "bp_payment_insert"

				.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput,,order_idx)
				.Parameters.Append .CreateParameter("@member_idx", adInteger, adParamInput, , MEMBER_IDX)
				.Parameters.Append .CreateParameter("@member_idno", adVarChar, adParamInput, 50, USER_ID)
				.Parameters.Append .CreateParameter("@member_type", adVarChar, adParamInput, 10, MEMBER_TYPE)
				.Parameters.Append .CreateParameter("@pay_amt", adCurrency, adParamInput,, PAYAMOUNT)
				.Parameters.Append .CreateParameter("@pay_status", adVarChar, adParamInput, 10, "PAID")

				.Parameters.Append .CreateParameter("@ERRCODE", adInteger, adParamOutput)
				.Parameters.Append .CreateParameter("@ERRMSG", adVarChar, adParamOutput, 500)

				.Execute

				errCode = .Parameters("@ERRCODE").Value
				errMsg = .Parameters("@ERRMSG").Value

			End With

			Set aCmd = Nothing
		End If
		Set aRs = Nothing

		'pay_detail 생성'
		Set aCmd = Server.CreateObject("ADODB.Command")

		'Response.Write "order_idx : " & order_idx & "<br />"
		'Response.Write "orderNo : " & ret_TxId & "<br />"
		'Response.Write "ret_Corporation : " & ret_Corporation & "<br />"
		'Response.Write "ret_Merchant : " & ret_Merchant & "<br />"
		'Response.Write "AMOUNT : " & AMOUNT & "<br />"
		'Response.Write "order_num : " & order_num & "<br />"
		'Response.End

		Dim pay_detail_idx

		With aCmd
			.ActiveConnection = dbconn
			.NamedParameters = True
			.CommandType = adCmdStoredProc
			.CommandText = "bp_payment_detail_insert"

			.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput,,order_idx)
			.Parameters.Append .CreateParameter("@pay_method", adVarChar, adParamInput, 10, "SGPAY")
			.Parameters.Append .CreateParameter("@pay_transaction_id", adVarChar, adParamInput, 50, ret_TxId)
			.Parameters.Append .CreateParameter("@pay_cp_id", adVarChar, adParamInput, 50, corporationToken)
			.Parameters.Append .CreateParameter("@pay_subcp", adVarChar, adParamInput, 50, ret_Merchant)
			.Parameters.Append .CreateParameter("@pay_amt", adCurrency, adParamInput,, AMOUNT)
			.Parameters.Append .CreateParameter("@pay_approve_num", adVarChar, adParamInput, 50, ret_PaymentNo)
			.Parameters.Append .CreateParameter("@pay_result_code", adVarChar, adParamInput, 10, "")
			.Parameters.Append .CreateParameter("@pay_err_msg", adVarChar, adParamInput, 1000, "")
			.Parameters.Append .CreateParameter("@pay_result", adLongVarWChar, adParamInput, 2147483647, "")
			.Parameters.Append .CreateParameter("@pay_detail_idx", adInteger, adParamOutput)

			.Execute

			pay_detail_idx = .Parameters("@pay_detail_idx").Value

		End With


		'sgpay_pay_log 생성'
		Set aCmd = Server.CreateObject("ADODB.Command")

		With aCmd
			.ActiveConnection = dbconn
			.NamedParameters = True
			.CommandType = adCmdStoredProc
			.CommandText = "bp_sgpay_log_insert"

			.Parameters.Append .CreateParameter("@act", adVarChar, adParamInput, 30, "PAY")
			.Parameters.Append .CreateParameter("@order_num", adVarChar, adParamInput, 50, order_num)
			.Parameters.Append .CreateParameter("@amt", adCurrency, adParamInput,, AMOUNT)
			.Parameters.Append .CreateParameter("@corporation", adVarChar, adParamInput, 32, corporationToken)
			.Parameters.Append .CreateParameter("@merchant", adVarChar, adParamInput, 32, ret_Merchant)
			.Parameters.Append .CreateParameter("@txid", adVarChar, adParamInput, 32, ret_TxId)
			.Parameters.Append .CreateParameter("@result", adVarChar, adParamInput, 10, "")
			.Parameters.Append .CreateParameter("@paymentno", adVarChar, adParamInput, 50, ret_PaymentNo)
			.Parameters.Append .CreateParameter("@paymenttime", adVarChar, adParamInput, 14, ret_PaymentTime)
			.Parameters.Append .CreateParameter("@errmsg", adVarChar, adParamInput, 1000, ErrMessage)
			.Parameters.Append .CreateParameter("@etc1", adLongVarWChar, adParamInput, 2147483647, "")
			.Parameters.Append .CreateParameter("@seq", adInteger, adParamOutput)

			.Execute

			sgpayco_log_idx = .Parameters("@seq").Value


		End With

		Set aCmd = Nothing

		Call Write_Log("bp_pay_detail_insert Execute. pay_detail_idx = " & pay_detail_idx)

		Response.Redirect "/order/orderEnd.asp?order_idx="& order_idx &"&pm=Sgpay"
		Response.End
	Else
		'-----------------------------------------------------------------------------
		'
		' 오류일 경우 오류페이지를 표시하거나 결제되지 않았음을 고객에게 통보합니다.
		' 팝업창 닫기 또는 구매 실패 페이지 작성 ( 팝업창 닫을때 Opener 페이지 이동 등 )
		'
		'-----------------------------------------------------------------------------
		'결제 인증 후 내부 오류가 있어 승인은 받지 않았습니다. 오류내역을 여기에 표시하세요. 예) 재고 수량이 부족합니다.
		Call Write_Log("sgpay_return.asp Error : " & ErrMessage)

		Set resMC = OrderCancelListForOrder(order_idx)

		If resMC.mCode = 0 Then
			paycoDone = True
		End If

	End if
%>