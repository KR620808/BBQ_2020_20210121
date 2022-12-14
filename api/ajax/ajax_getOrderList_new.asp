<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include virtual="/api/include/db_open.asp"-->
<!--#include virtual="/api/include/g2.asp"-->
<%
	REFERERURL	= Request.ServerVariables("HTTP_REFERER")
    If Request.ServerVariables("HTTPS") = "on" Then
        GetUrlProtocol = "https"
    Else
        GetUrlProtocol = "http"
    End If
	GetUrlHost = Request.ServerVariables("HTTP_HOST")
    GetCurrentHost = GetUrlProtocol & "://" & GetUrlHost

	If left(REFERERURL,19) = left(GetCurrentHost,19) Then 
	Else 
		orderList = "[]"
		Response.ContentType = "application/json"
		Response.Write orderList
		Response.End 
	End If

	orderList = "[]"

    pageSize = Request("pageSize")
    curPage = Request("curPage")

    If IsEmpty(pageSize) Or IsNull(pageSize) Or Trim(pageSize) = "" Or Not IsNumeric(pageSize) Then pageSize = 10
    If IsEmpty(curPage) Or IsNull(curPage) Or Trim(curPage) = "" Or Not IsNumeric(curPage) Then curPage = 1

    If Session("userIdNo") <> "" Then
        Set aCmd = Server.CreateObject("ADODB.Command")
        With aCmd
            .ActiveConnection = dbconn
            .NamedParameters = True
            .CommandType = adCmdStoredProc
            .CommandText = "bp_order_list_member"

            .Parameters.Append .CreateParameter("@member_idno", adVarChar, adParamInput, 50, Session("userIdNo"))
            .Parameters.Append .CreateParameter("@pageSize", adInteger, adParamInput, , pageSize)
            .Parameters.Append .CreateParameter("@curPage", adInteger, adParamInput, ,curPage)
            .Parameters.Append .CreateParameter("@totalCount", adInteger, adParamOutput)

            Set aRs = .Execute

            totalCount = .Parameters("@totalCount").Value
        End With
        Set aCmd = Nothing

        If Not (aRs.BOF Or aRs.EOF) Then
            aRs.MoveFirst
            orderList = "["
            Do Until aRs.EOF
                If orderList <> "[" Then orderList = orderList & ","

				' 제주/산간 =========================================================================================
				plus_price = 0
				Set pCmd = Server.CreateObject("ADODB.Command")
				With pCmd
					.ActiveConnection = dbconn
					.NamedParameters = True
					.CommandType = adCmdStoredProc
					.CommandText = "bp_order_detail_select_1138"

					.Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput, , aRs("order_idx"))

					Set pRs = .Execute
				End With
				Set pCmd = Nothing


				If Not (pRs.BOF Or pRs.EOF) Then
					plus_price = (pRs("menu_price")*pRs("menu_qty"))
				End If

                ' 상품권 적용 유무 체크 후 가격 지정
                giftcard_amt = 0
                giftcardAmt = " SELECT giftcard_amt as amt FROM bt_giftcard WHERE order_num = '" & aRs("order_num") &"'"
                Set giftAmount = dbconn.Execute(giftcardAmt)
                
                If Not (giftAmount.BOF Or giftAmount.EOF) Then
                     giftcard_amt = giftAmount("amt")
                    'Response.Write "giftAmount ::::: " & giftAmount("amt")
                    'Response.Write "giftcard_amt ::::: " & giftcard_amt
                end If
                ' 상품권 적용 유무 체크 후 가격 지정

				' =========================================================================================

                orderList = orderList & "{"
                orderList = orderList & """order_idx"":" & aRs("order_idx") & ","
                orderList = orderList & """order_num"":""" & aRs("order_num") & ""","
                orderList = orderList & """brand_code"":""" & aRs("brand_code") & ""","
                orderList = orderList & """brand_name"":""" & aRs("brand_name") & ""","
                orderList = orderList & """branch_id"":""" & aRs("branch_id") & ""","
                orderList = orderList & """branch_name"":""" & aRs("branch_name") & ""","
                orderList = orderList & """order_date"":""" & aRs("order_date") & ""","
                orderList = orderList & """order_date_time"":""" & aRs("order_date_time") & ""","
                orderList = orderList & """DELIVERYTIME"":""" & aRs("DELIVERYTIME") & ""","
                orderList = orderList & """menu_name"":""" & aRs("menu_name") & ""","
                orderList = orderList & """menu_count"":" & aRs("menu_count") & ","
                orderList = orderList & """order_amt"":" & aRs("order_amt")+plus_price-giftcard_amt & ","
                orderList = orderList & """order_type"":""" & aRs("order_type") & ""","
                orderList = orderList & """order_type_name"":""" & aRs("order_type_name") & ""","
                orderList = orderList & """pay_type_name"":""" & aRs("pay_type_name") & ""","
                orderList = orderList & """order_status"":""" & aRs("state") & ""","
                orderList = orderList & """order_status_class"":""" & order_status_class(aRs("order_type"), aRs("order_status_name")) & ""","
                orderList = orderList & """order_status_name"":""" & order_status_txt(aRs("order_type"), aRs("order_status_name")) & ""","
                orderList = orderList & """order_step"":""" & aRs("order_step") & ""","
                orderList = orderList & """addr_idx"":""" & aRs("addr_idx") & ""","
                orderList = orderList & """membership_yn_code"":""" & aRs("membership_yn_code") & ""","
                orderList = orderList & """branch_tel"":""" & aRs("branch_tel") & ""","
                orderList = orderList & """wgs84_x"":""" & aRs("wgs84_x") & ""","
                orderList = orderList & """wgs84_y"":""" & aRs("wgs84_y") & ""","
                orderList = orderList & """delivery_zipcode"":""" & aRs("delivery_zipcode") & ""","
                orderList = orderList & """delivery_address"":""" & aRs("delivery_address") & ""","
                orderList = orderList & """delivery_address_detail"":""" & aRs("delivery_address_detail") & ""","
                orderList = orderList & """delivery_time"":""" & aRs("delivery_time") & """"
                orderList = orderList & "}"

                aRs.MoveNext
            Loop
            orderList = orderList & "]"
        End If

        Set aRs = Nothing
    End If

    Response.Write orderList
%>