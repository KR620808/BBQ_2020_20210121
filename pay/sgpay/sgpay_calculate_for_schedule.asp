<!--#include file="sgpay.inc.asp"-->
<%
	Dim delayTime, rDate, sDate, eDate
	delayTime	= 2
	rDate			= GetReqStr("rDate", Date()-1)
	sDate		= GetReqStr("sDate", rDate)
	eDate		= GetReqStr("eDate", DateAdd("d", 1, rDate))
	'Response.End

	' 매장정보 조회...
	Query = "SELECT * FROM BT_BRANCH WITH(NOLOCK) WHERE LEN(ISNULL(sgpay_merchant, '')) > 0"
	Set Rlist = dbconn.Execute(Query)

	If Not Rlist.Eof Then
		Do While Not Rlist.Eof
			branch_id			= Rlist("BRANCH_ID")
			merchantToken	= Rlist("SGPAY_MERCHANT")

			'-----------------------------------------------------------------------------
			' 정산 내역을 담을 JSON OBJECT를 선언합니다.
			'-----------------------------------------------------------------------------
			Dim calculateOrder
			Set calculateOrder = New aspJSON
			With calculateOrder.data
				'---------------------------------------------------------------------------------
				' 설정한 주문정보 변수들로 Json String 을 작성합니다.
				'---------------------------------------------------------------------------------
				.Add "Corporation", CStr(corporationToken)				' 가맹점 코드
				.Add "Merchant", CStr(merchantToken)					' 가맹점 코드

				'---------------------------------------------------------------------------------
				' 거래(주문)정보
				'---------------------------------------------------------------------------------
				Dim orderList
				Set orderList = New aspJson
				With orderList.data
					orderListSql = ""
					If delayTime > 0 Then
						dbconn.commandTimeout = delayTime + 5
						orderListSql = "WAITFOR DELAY '00:00:" & Right(CLng(delayTime), 2) & "' "
					End If
					orderListSql = orderListSql & " SELECT A.order_id, A.list_price, B.paymenttime, B.paymentno, B.act, B.amt"
					orderListSql = orderListSql & " FROM TB_WEB_ORDER_MASTER A"
					orderListSql = orderListSql & " JOIN bt_sgpay_log B ON B.order_num = A.order_id"
					orderListSql = orderListSql & " WHERE A.USE_PAY_METHOD = 'SGPAY_000001'"
					orderListSql = orderListSql & " AND A.branch_id = '" & branch_id & "'"
					orderListSql = orderListSql & " AND B.corporation = '" & corporationToken & "'"
					orderListSql = orderListSql & " AND B.regdate >= '" & sDate & "'"
					orderListSql = orderListSql & " AND B.regdate <  '" & eDate &"'"
					orderListSql = orderListSql & " ORDER BY A.cdate DESC, A.ctime DESC"
					'Response.Write orderListSql & "<br />"
					Set orderListRow = dbconn.Execute(orderListSql)
					If Not orderListRow.Eof Then
						num = 1
						Do While Not orderListRow.Eof
							TradeNo				= orderListRow("order_id")
							Amount				= orderListRow("list_price")
							PaymentTime		= orderListRow("paymenttime")
							PaymentNo		= orderListRow("paymentno")
							IsCanCel			= ""
							CancelAmount	= ""
							CancelTime		= ""
							Act					= orderListRow("act")
							If Act = "CANCEL" Then
								IsCancel			= "Y"
								CancelAmount	= orderListRow("amt")
								CancelTime		= PaymentTime
							End If
							'Response.Write TradeNo & "<br /><br />"

							.Add num, orderList.Collection()
							With .item(num)
								.add "TradeNo", TradeNo
								.add "Amount", Amount
								.add "PaymentTime", PaymentTime
								.add "PaymentNo", PaymentNo
								.add "IsCancel", IsCanCel
								.add "CancelAmount", CancelAmount
								.add "CancelTime", CancelTime
							End With
							orderListRow.MoveNext
							num = num + 1
						Loop
					End If
					orderListRow.Close
					Set orderListRow = Nothing
				End With

				.add "OrderList", orderList.data
			End With


			'---------------------------------------------------------------------------------
			' 암호화
			'---------------------------------------------------------------------------------
			encryptedJson = Com.encrypt(calculateOrder.JSONoutput(), secretkey)

			'---------------------------------------------------------------------------------
			' 정산 API 호출 ( JSON 데이터로 호출 )
			'---------------------------------------------------------------------------------
			Call Write_Log("calculateOrder.JSONoutput() : " & calculateOrder.JSONoutput())
			Result = sgpay_calculate("token=" & encryptedJson)
			Call Write_Log("Result : " & Result)

			Dim Verify_Read_Data
			Dim TotalTradeCount, TotalPaymentAmount, TotalCancelCount, TotalCancelAmount
			Set Verify_Read_Data = New aspJSON
			Verify_Read_Data.loadJSON(Result)

			TotalTradeCount			= FormatNumber(Verify_Read_Data.data("TotalTradeCount"), 0)
			TotalPaymentAmount	= FormatNumber(Verify_Read_Data.data("TotalPaymentAmount"), 0)
			TotalCancelCount		= FormatNumber(Verify_Read_Data.data("TotalCancelCount"), 0)
			TotalCancelAmount		= FormatNumber(Verify_Read_Data.data("TotalCancelAmount"), 0)

			req_datetime = CStr(year(date) & Right("0" & month(date),2) & Right("0" & day(date),2) & Right("0" & hour(time),2) & Right("0" & minute(time),2) & Right("0" & second(time),2))
			req_msg = "총 주문 건수 : " & TotalTradeCount & " 건||총 결제 금액 : " & TotalPaymentAmount & " 원||총 취소 건수 : " & TotalCancelCount & " 건||총 취소 금액 : " & TotalCancelAmount & " 원"
			'Response.Write req_msg & "<br />"
			'Response.Write Result & "<br /><br />"

			'sgpay_log 생성'
			Set aCmd = Server.CreateObject("ADODB.Command")

			With aCmd
				.ActiveConnection = dbconn
				.NamedParameters = True
				.CommandType = adCmdStoredProc
				.CommandText = "bp_sgpay_log_insert"

				.Parameters.Append .CreateParameter("@act", adVarChar, adParamInput, 30, "CALCULATE")
				.Parameters.Append .CreateParameter("@order_num", adVarChar, adParamInput, 50, "")
				.Parameters.Append .CreateParameter("@amt", adCurrency, adParamInput,, TotalPaymentAmount)
				.Parameters.Append .CreateParameter("@corporation", adVarChar, adParamInput, 32, corporationToken)
				.Parameters.Append .CreateParameter("@merchant", adVarChar, adParamInput, 32, merchantToken)
				.Parameters.Append .CreateParameter("@txid", adVarChar, adParamInput, 32, "")
				.Parameters.Append .CreateParameter("@result", adVarChar, adParamInput, 2000, Result)
				.Parameters.Append .CreateParameter("@paymentno", adVarChar, adParamInput, 50, "")
				.Parameters.Append .CreateParameter("@paymenttime", adVarChar, adParamInput, 14, "")
				.Parameters.Append .CreateParameter("@errmsg", adVarChar, adParamInput, 2000, req_msg)
				.Parameters.Append .CreateParameter("@etc1", adLongVarWChar, adParamInput, 2147483647, "")
				.Parameters.Append .CreateParameter("@seq", adInteger, adParamOutput)

				.Execute

				sgpayco_log_idx = .Parameters("@seq").Value

			End With

			Set aCmd = Nothing

			Rlist.MoveNext
		Loop
	End If
	Rlist.Close
	Set Rlist = Nothing
%>
<script type="text/javascript">
window.opener='Self'; // 윈도창을 안닫아 주면 처리완료후 프로세스가 계속 남아잇음.
window.open('','_parent','');
window.close();
</script>