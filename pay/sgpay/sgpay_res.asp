<!--#include file="sgpay.inc.asp"-->
<!doctype html>
<html lang="ko">
<head>

<!--#include virtual="/includes/top.asp"-->
<%
	If Not CheckLogin() Then
%>
	<script type="text/javascript">
		showAlertMsg({
			msg:"BBQ PAY 는 회원만 이용가능합니다.",
			ok: function() {
				self.close();
			}
		});
	</script>
<%
		Response.End
	End If
%>

<title>BBQ PAY | BBQ치킨</title>

</head>
<%
	'-----------------------------------------------------------------------------
	' SGPay 주문 예약 페이지 샘플 ( ASP )
	' sgpay_res.asp
	' 2019-12-10	Sewoni31™
	'-----------------------------------------------------------------------------

	'-----------------------------------------------------------------------------
	' 이 문서는 json 형태의 데이터를 반환합니다.
	'-----------------------------------------------------------------------------
	Response.ContentType = "application/json"

	' 비비큐 주문정보 셋팅
	gubun = GetReqStr("gubun", "")
	domain = GetReqStr("domain", "")
	branch_id = GetReqStr("branch_id", "")
	cart_value = GetReqStr("cart_value", "")

	If branch_id = "" Then
%>
<script>
	alert('매장정보가 없습니다.');
	if (window.opener) {
		self.close();
	} else {
		history.back();
	}
</script>
<%
		Response.End
	End If

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

	vUseDANAL = "N"
	vUsePAYCO = "N"

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
		vSgpay_Merchantcd = aRs("sgpay_merchant")

		If vSgpay_Merchantcd = "" Then
%>
<script>
	alert("BBQ PAY 가맹점이 아닙니다.");
	if (window.opener) {
		self.close();
	} else {
		history.back();
	}
</script>
<%
			Set aRs = Nothing
			response.End
		End If
	Else
%>
<script>
	alert("매장정보가 없습니다.");
	if (window.opener) {
		self.close();
	} else {
		history.back();
	}
</script>
<%
		Set aRs = Nothing
		response.End
	End If

	If Not IsNumeric(vDeliveryFee) Then vDeliveryFee = 0

	If order_type = "P" Then vDeliveryFee = 0

	Set aRs = Nothing

	order_idx = GetReqNum("order_idx", "")
	order_num = GetReqStr("order_num","")
	pay_method = GetReqStr("pay_method","")

	Response.Cookies("GUBUN") = gubun
	Response.Cookies("ORDER_IDX") = order_idx

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
		USER_ID			= pRs("member_idno")
		DELIVERY_FEE	= pRs("delivery_fee")
		AMOUNT			= pRs("order_amt")-pRs("discount_amt")
	Else
		USER_ID			= ""
		DELIVERY_FEE	= ""
		AMOUNT			= ""
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

	userAgent = ""
	Select Case domain
		Case "pc": userAgent = "WP"
		Case "mobile": userAgent = "WM"
	End Select

	'-----------------------------------------------------------------------------
	' (로그) 호출 시점과 호출값을 파일에 기록합니다.
	'-----------------------------------------------------------------------------
	Dim xform, receive_str
	receive_str = "sgpay_res.asp is Called - "
	For Each xform In Request.form
		receive_str = receive_str +  CStr(xform) + " : " + request(xform) + ", "
	Next
	Call Write_Log(receive_str)

	'---------------------------------------------------------------------------------
	' 이전 페이지에서 전달받은 고객 주문번호 설정
	'---------------------------------------------------------------------------------
	Dim customerOrderNumber

	customerOrderNumber = order_num'request("customerOrderNumber")

	'---------------------------------------------------------------------------------
	' 상품정보 변수 선언 및 초기화
	'---------------------------------------------------------------------------------
	Dim OrderNumber, i
	Dim orderQuantity, productUnitPrice, productUnitPaymentPrice, productAmt, productPaymentAmt, TotalProductPaymentAmt
	Dim productName, productPrice, productQuantity, couponPin


	'---------------------------------------------------------------------------------
	' 변수 초기화
	'---------------------------------------------------------------------------------
	TotalProductPaymentAmt = 0		'주문 상품이 여러개일 경우 상품들의 총 금액을 저장할 변수
	OrderNumber = 0					'주문 상품이 여러개일 경우 순번을 매길 변수

	'---------------------------------------------------------------------------------
	' 구매 상품을 변수에 셋팅 ( JSON 문자열을 생성 )
	'---------------------------------------------------------------------------------
	With jsonOrder.data

		'---------------------------------------------------------------------------------
		' 상품정보 값 입력(여러개의 상품일 경우 묶어서 한개의 정보로 포함해서 보내주시면 됩니다. 배송비 포함)
		'---------------------------------------------------------------------------------
		OrderNumber = OrderNumber + 1										' 상품에 순번을 정하기 위해 값을 증가합니다.

		orderQuantity =	1													' (필수) 주문수량 (배송비 상품인 경우 1로 세팅)
		'상품단가(productAmt)는 원 상품단가이고 상품결제단가(productPaymentAmt)는 상품단가에서 할인등을 받은 금액입니다. 실제 결제에는 상품결제단가가 사용됩니다.
		productUnitPrice = AMOUNT											' (필수) 상품 단가 ( 테스트용으로써 70,000원으로 설정. )
		productUnitPaymentPrice = AMOUNT										' (필수) 상품 결제 단가 ( 테스트용으로써 69,000원으로 설정. )

		productAmt = productUnitPrice * orderQuantity						' (필수) 상품 결제금액(상품단가 * 수량)
		productPaymentAmt = productUnitPaymentPrice * orderQuantity			' (필수) 상품 결제금액(상품결제단가 * 수량)
		TotalProductPaymentAmt = TotalProductPaymentAmt + productPaymentAmt	' 주문정보를 구성하기 위한 상품들 누적 결제 금액(상품 결제 금액), 면세금액,과세금액,부가세의 합

		'---------------------------------------------------------------------------------
		' 주문정보 변수 선언
		'---------------------------------------------------------------------------------
		Dim totalOrderAmt, totalDeliveryFeeAmt, totalPaymentAmt
		Dim resultUrl, successUrl
		'---------------------------------------------------------------------------------

		'---------------------------------------------------------------------------------
		' 주문정보 값 입력 ( 가맹점 수정 가능 부분 )
		'---------------------------------------------------------------------------------
		totalOrderAmt = TotalProductPaymentAmt									' (필수) 총 주문금액. 지수형태를 피하고 문자열로 보낼려면 formatnumber(TotalProductPaymentAmt,0,,,0)
		totalDeliveryFeeAmt = DELIVERY_FEE													' 총 배송비(상품가격에 포함).
		totalPaymentAmt = totalOrderAmt+totalDeliveryFeeAmt						' (필수) 총 결재 할 금액.
		successUrl = AppWebPath & "/order/orderComplete.asp?order_idx=" & order_idx & "&pm=Sgpay"								' 결제 완료 후 리다이렉트 할 사이트 URL
		resultUrl = AppWebPath & "/pay/sgpay/sgpay_return.asp?order_idx=" & order_idx					' 결제 결과 받을 Server-to-Server API URL


		'---------------------------------------------------------------------------------
		' 상품정보
		'---------------------------------------------------------------------------------
		Dim productsList
		Set productList = New aspJson
		With productList.data
			Dim cJson : Set cJson = JSON.Parse(cart_value)
			Dim iLen : iLen = cJson.length
			For i = 0 To iLen - 1
				productName		= CStr(cJson.get(i).value.nm)
				productPrice		= cJson.get(i).value.price
				productQuantity	= cJson.get(i).value.qty
				couponPin			= cJson.get(i).value.pin

				If couponPin <> "" Then
					productName	= productName & "[E-쿠폰]"
					productPrice	= 0
				End If

				.Add i, productList.Collection()
				With .item(i)
					.add "Name", productName
					.add "Price", productPrice
					.add "Quantity",productQuantity
				End With
			Next

			' 배달비 전송 추가 | 2020-05-07 | Sewoni31™
			If totalDeliveryFeeAmt <> 0 Then
				.Add iLen, productList.Collection()
				With .item(iLen)
					.add "Name", CStr("배달비")
					.add "Price", totalDeliveryFeeAmt
					.add "Quantity", 1
				End With
			End If
		End With


		'---------------------------------------------------------------------------------
		' 거래(주문)정보
		'---------------------------------------------------------------------------------
		.Add "Trade", jsonOrder.Collection()

		With jsonOrder.data("Trade")
			.add "Merchant", CStr(vSgpay_Merchantcd)
			.add "TradeNo", CStr(customerOrderNumber)
			.add "Amount", totalPaymentAmt
			.add "Products", productList.data
		End With


		.Add "RequestTime", CStr(year(date) & Right("0" & month(date),2) & Right("0" & day(date),2) & Right("0" & hour(time),2) & Right("0" & minute(time),2) & Right("0" & second(time),2))			' 결제 요청 일시(yyyyMMddHHmmss)
		.Add "SuccessUrl",  CStr(successUrl)			' 결제 결과 URL
		.Add "ResultUrl", CStr(resultUrl)				' 결제 완료 URL

	End With

	'---------------------------------------------------------------------------------
	' 주문 예약 함수 호출 ( JSON 데이터를 String 형태로 전달 )
	'---------------------------------------------------------------------------------
	'Result = sgpay_reserve(jsonOrder.JSONoutput())
	Result = jsonOrder.JSONoutput()
	Call Write_Log("jsonOrder.JSONoutput() : " + Result)


	'---------------------------------------------------------------------------------
	' 암호화
	'---------------------------------------------------------------------------------
	encryptedJson = Com.encrypt(Result, secretkey)


	'---------------------------------------------------------------------------------
	' 결과 그대로를 호출쪽에 반환
	'---------------------------------------------------------------------------------
	'Response.Write encryptedJson
	Response.Redirect sgPayPayUrl & encryptedJson
%>