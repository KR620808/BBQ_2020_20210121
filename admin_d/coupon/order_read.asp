<!-- #include virtual="/inc/config.asp" -->
<%
	CUR_PAGE_CODE = "B"
	CUR_PAGE_SUBCODE = ""
%>
<!-- #include virtual="/inc/admin_check.asp" -->
<%
	OID		= InjRequest("OID")
	If FncIsBlank(OID) Then 
		Call subGoToMsg("잘못된 접근방식 입니다","close")
	End If
%>
<script language="JavaScript">
function AddCMS(){
	wrapWindowByMask();
}
var checkClick = 0;
function CheckInput(){
	if ( checkClick == 1 ) {
		alert('등록중입니다. 잠시 기다려 주시기 바랍니다.');
		return;
	}
	var f = document.inputfrm;
	if(f.username.value.length < 1){alert("상담자를 입력해 주세요");f.username.focus();return;}
	if(f.note1.value.length < 1){alert("상담내용을 입력해 주세요");f.note1.focus();return;}

	if (f.proc[0].checked){
		if (!confirm('정말로 취소하시겠습니까?.\n취소된 주문건은 복구가 불가능합니다'))	{
			return;
		}
	}
	checkClick = 1;
	$.ajax({
		async: false,
		type: "POST",
		url: "order_cms_proc.asp",
		data: $("#inputfrm").serialize(),
		dataType : "text",
		success: function(data) {
			if (data.split("^")[0] == "Y") {
				document.location.reload();
			}else{
				alert(data.split("^")[1]);
				checkClick = 0;
			}
		},
		error: function(data, status, err) {
			checkClick = 0;
			alert(err + '서버와의 통신이 실패했습니다.');
		}
	});
}
</script>
		<!--popup-->
        <div class="mask"></div>
        <div class="window">
            <div class="sitemap_wrap">
                <!--content-->
                <div class="manager_popup_area" style="height:350px;">
                    <form id="inputfrm" name="inputfrm">
					<input type="hidden" name="orderid" value="<%=OID%>">
					<input type="hidden" name="cms_type" value="ADMIN">
					<div class="popup_title">
						<span>상담 내역 및 주문취소</span>
						<a href="javascript:;" class="close"><img src="../img/close.png" alt=""></a>
					</div>
					<table>
						<colgroup>
							<col width="30%">
							<col width="70%">
						</colgroup>
						<tr>
							<th>상담자</th>
							<td><input type="text" name="username"></td>
						</tr>
						<tr>
							<th>상담내용</th>
							<td><textarea name="note1" style="width:95%;height:120px;"></textarea></td>
						</tr>
						<tr>
							<th>처리상태</th>
							<td style="text-align: left;padding-left:20px;">
								<div><label><input type="radio" name="proc" value="C">주문취소</label></div>
								<div><label><input type="radio" name="proc" value="R" checked>주문상담(주문취소가 되지 않고 상담내역만 등록</label></div>
							</td>
						</tr>
					</table>
					<div class="popup_btn">
						<input type="button" value="등록" class="btn_red125" onClick="CheckInput();">
						<input type="button" value="취소" class="btn_white125" onClick="$('.mask, .window').hide();">
					</div>
                    </form>
                </div>
                <!--//content-->
            </div>
        </div>
        <!--//popup-->
<%
	Sql = "	SELECT A.*, ( A.LIST_PRICE - (SELECT ISNULL(SUM(LIST_PRICE) * -1, 0) FROM TB_WEB_ORDER_ITEM WITH(NOLOCK) WHERE ORDER_ID = '"& OID &"' AND ORD_TYPE <> '10') ) AS LAST_PRICE, "	& _
		"	    B.BRANCH_NAME, B.BRANCH_PHONE, C.STATE, "	& _
		"		ISNULL( (SELECT ABS(SUM(LIST_PRICE)) As CLPRICE FROM TB_WEB_ORDER_ITEM WHERE ORDER_ID = '"& OID &"' AND ORD_TYPE = '20' AND SESSION_ID LIKE 'CL|%' GROUP BY ORD_TYPE) ,0) AS CLPRICE, "	& _
		"	    (SELECT TNO FROM TB_WEB_KCP_LOG WITH(NOLOCK) WHERE ORDR_ID='"& OID &"' AND res_cd='0000') TNO "	& _
		"        , (SELECT TOP 1 CODE_DESC FROM BBQ_HOME_OLD.DBO.T_MST_CODE WITH(NOLOCK) WHERE CODE_GROUP = 'PAYMETHOD' AND CODE_ID = A.USE_PAY_METHOD AND USE_YN = 'Y') AS USE_PAY_METHOD_NAME "	& _
		"        , BBQ_HOME_OLD.DBO.[FN_GET_CODE]( 'ORDER_FLAG', A.ORDER_FLAG, 'CODE_DESC') AS ORDER_FLAG_NM "	& _
		"	FROM TB_WEB_ORDER_MASTER A WITH(NOLOCK) "	& _
		"    INNER JOIN BT_BRANCH B WITH(NOLOCK) ON A.BRANCH_ID = B.BRANCH_ID "	& _
		"    INNER JOIN TB_WEB_ORDER_STATE C WITH(NOLOCK) ON A.ORDER_ID=C.ORDER_ID "	& _
		"	WHERE A.ORDER_ID = '"& OID &"'"
	Set oRs = conn.Execute(Sql)
	If oRs.eof Then 
		Call subGoToMsg("잘못된 접근방식 입니다","back")
	End If

	order_memo      = oRs("ORDER_MEMO")

    list_price      = oRs("LIST_PRICE")
    disc_price      = oRs("DISC_PRICE")
    last_price      = oRs("LAST_PRICE")
    si              = oRs("SI")
    gu              = oRs("GU")
    dong            = oRs("DONG")
    bunji           = oRs("BUNJI")
    building        = oRs("BUILDING")
    addr_append     = oRs("ADDR_APPEND")
    phone_region    = oRs("PHONE_REGION")
    phone           = oRs("PHONE")
    a_branch_name   = oRs("BRANCH_NAME")
    a_phone         = oRs("BRANCH_PHONE")
    iname           = oRs("CUST_NAME")
    iTNo            = oRs("TNO")
    iOrder_flag     = oRs("order_flag")
    icdate          = oRs("cdate")
    ctime           = oRs("ctime")
    cust_Id         = oRs("cust_Id")
    branch_id       = oRs("branch_id")
    iState          = oRs("STATE")
    USE_PAY_METHOD  = oRs("USE_PAY_METHOD")
    CLPRICE         = oRs("CLPRICE")
    brand_id        = oRs("brand_id")
'    USE_PAY_TYPE    = oRs("USE_PAY_METHOD_NAME")

    ' 3자리수마다 콤마
    if list_price > 0 then
        list_price = FormatNumber(list_price,0)
    end if

    if disc_price > 0 then
        disc_price = FormatNumber(disc_price,0)
    end if

    if last_price > 0 then
        last_price = FormatNumber(last_price,0)
    end if

    cust_addr   = si&" "&Trim(gu)&" "&Trim(dong)&" "&Trim(bunji)&" "&Trim(building)&" "&Trim(addr_append)
    sPhone  = getFormatPhoneNumber(Trim(phone_region)&Trim(phone))

    If USE_PAY_METHOD = "000000000000" Or USE_PAY_METHOD = "" Then
        last_Price2 = 0 '후불이면
    Else
        last_Price2 = Last_Price - CLPRICE '후불이 아니라면
    End if

'결제금액
'   Vlist_Price = last_Price2 + CLPRICE + disc_price
    Vlist_Price = (list_price - last_price)
    Vlist_Price = FormatNumber(Vlist_Price,0)
'결제잔액
'   Vlast_Price = last_Price - CLPRICE - last_Price2
    Vlast_Price = last_price
    Vlast_Price = FormatNumber(Vlast_Price,0)

    Dim Order_flag
    Select Case iOrder_flag
        Case "1"
            Order_flag="콜 주문"
        Case "2"
            Order_flag="웹 주문"
        Case "3"
            Order_flag="모바일 주문"
        Case "4"
            Order_flag="티몬"
        Case "5"
            Order_flag="안드로이드 주문"
        Case "6"
            Order_flag="아이폰 주문"
        Case "7"
            Order_flag="아리아 주문"
    End Select

	If LAST_PRICE = "0원" Or LAST_PRICE = "0" then
		USE_PAY_TYPE = "<span style='color:red;'>선불<span>"
	Else 
		USE_PAY_TYPE = "후불"
	End If

    If CLPRICE > 0 Then
        If CLng(last_price) - CLPRICE > 0 Then
            USE_PAY_TYPE = USE_PAY_TYPE & " (" & FormatNumber(CLng(last_price) - CLPRICE, 0) & "원) / "
        Else
            USE_PAY_TYPE = ""
        End If
        USE_PAY_TYPE = USE_PAY_TYPE + "문화상품권(" + FormatNumber(CLPRICE, 0) + "원)"
    End If

	If USE_PAY_METHOD = "DANAL_000001" Then
		USE_PAY_METHOD_TXT = "핸드폰"
	ElseIf USE_PAY_METHOD = "DANAL_000002" Then
		USE_PAY_METHOD_TXT = "신용카드"
	ElseIf USE_PAY_METHOD = "DANAL_000003" Then
		USE_PAY_METHOD_TXT = "카카오페이"
	ElseIf USE_PAY_METHOD = "PCO_00000001" Then
		USE_PAY_METHOD_TXT = "페이코"
	ElseIf USE_PAY_METHOD = "PCOIN_000001" Then
		USE_PAY_METHOD_TXT = "페이코인"
	Else
		USE_PAY_METHOD_TXT = "기타"
	End If

	oRs.close
	Set oRs = Nothing 
%>
        <div class="content">
            <div class="section section_order_detail">
				<div class="db_all">
					<div class="db db_1">
						<div class="txt_t">
							<b>주문정보A</b>
						</div>
						<div class="ta ta_1">
							<table>
								<tr>
									<th>주문번호</th>
									<th>주문형태</th>
									<th>주문날짜</th>
									<th>주문시간</th>
									<th>메모</th>
								</tr>
								<tr>
									<td><%=OID%></td>
									<td><%=Order_flag%></td>
									<td><%=icdate%></td>
									<td><%=ctime%></td>
									<td><%=order_memo%></td>
								</tr>
							</table>
						</div>
					</div>
		
					<div class="db db_2">
						<div class="txt_t">
							<b>주문상품정보</b>
						</div>
						<div class="ta ta_1">
							<table>
<%
	Sql = "EXEC UP_ORDER_MYMENU_5 '"& OID &"'"
	Set oRs = conn.Execute(Sql)
	If Not oRs.Eof Then 
		Do While Not oRs.Eof
			If oRs("M_CSER2") = "1" Then
				If oRs("LIST_TYPE") = "ORDER" Then
%>
								<tr>
									<th>상품명</th>
									<th>단가</th>
									<th>수량</th>
									<th>금액</th>
								</tr>
<%
		     ElseIf oRs("LIST_TYPE") = "PAY" Then
%>
								<tr>
									<th>결제방법</th>
									<th>&nbsp;</th>
									<th>&nbsp;</th>
									<th>금액</th>
								</tr>
<%
				End If
			End If
			MENU_NM = oRs("MENU_NM")
			FPRC = oRs("M_FPRC")
			FQTY = oRs("M_FQTY")
			FAMT = oRs("M_FAMT")

			Select Case STATE
				Case "P"
					STATETYPE = "변경가능"
				Case "N"
					STATETYPE = "신규주문"
				Case "M"
					STATETYPE = "주문적용"
				Case "C"
					STATETYPE = "취소요청"
				Case "B"
					STATETYPE = "주문취소"
				Case "Z"
					STATETYPE = "매장취소"
				Case "X"
					STATETYPE = "에러"
			End Select

			If oRs("M_CSER2") = "99" Then
				rowBgColor = "#faf4c0"
				rowColor = "#000000"
			ElseIf oRs("MENU_NM") = "현장결제" Then
				rowBgColor = "#f9808b"
				rowColor = "#000000"
			Else
				rowBgColor = "#FFFFFF"
				rowColor = "#000000"
			End If
%>
								<tr bgcolor="<%=rowBgColor%>" style="color:<%=rowColor%>">
									<td><%=MENU_NM %></td>
									<td><%=FormatNumber(FPRC, 0)%>원</td>
									<td><%=FQTY%></td>
									<td><%=FormatNumber(FAMT, 0)%>원</td>
								</tr>
<%
			oRs.MoveNext
		Loop
	End If 
	oRs.close
	Set oRs = Nothing 
%>
							</table>
						</div>
					</div>
		
					<div class="db db_3">
						<div class="txt_t">
							<b>결제정보</b>
						</div>
						<div class="ta ta_1">
							<table>
								<tr>
									<th>결제유형</th>
									<th>결제방법</th>
									<th>판매금액</th>
									<th>사용포인트</th>
									<th>결제금액</th>
									<th>결제잔액</th>
								</tr>
								<tr>
									<td><%=USE_PAY_TYPE%></td>
									<td><%=USE_PAY_METHOD_TXT%></td>
                                    <td><%=FormatNumber(List_Price,0) %></td>
                                    <td>?</td>
                                    <td><%=FormatNumber(PAID_PRICE,0) %></td>
                                    <td><%=FormatNumber(LAST_PRICE,0) %></td>
								</tr>
							</table>
						</div>
					</div>
		
					<div class="db db_4">
						<div class="txt_t">
							<b>포인트&amp;쿠폰 사용 정보</b>
						</div>
						<div class="ta ta_1">
							<table>
								<tr>
									<th colspan="2">포인트</th>
									<th colspan="5">쿠폰</th>
								</tr>
								<tr>
									<td class="bg_fa">사용포인트</td>
									<td class="bg_fa">잔여포인트</td>
									<td class="bg_fa">쿠폰명</td>
									<td class="bg_fa">핀번호</td>
									<td class="bg_fa">적용상품</td>
									<td class="bg_fa">적용금액</td>
									<td class="bg_fa">사용일</td>
								</tr>
<%
	Sql = "EXEC UP_ORDER_MYCOUPON '"& OID &"'"
	Set oRs = conn.Execute(Sql)
	If Not oRs.Eof Then 
		Do While Not oRs.Eof
%>
								<tr class="h20">
									<td>?</td>
									<td>?</td>
									<td><%=oRs("CPNNAME")%></td>
									<td><%=oRs("PIN")%></td>
									<td><%=oRs("MENUNAME_K")%></td>
									<td>?</td>
									<td><%=oRs("CDATE")%></td>
								</tr>
<%
			oRs.MoveNext
		Loop
	End If 
%>
							</table>
						</div>
					</div>
		
					<div class="db db_5">
						<div class="txt_t">
							<b>배송정보&amp;주문매장정보</b>
						</div>
						<div class="ta ta_1">
							<table>
								<tr>
									<th>회원명</th>
									<th>회원ID</th>
									<th>회원연락처</th>
									<th>배송받을주소</th>
									<th>주문브랜드</th>
									<th>주문매장명</th>
									<th>주문매장연락처</th>
									<th>사용일</th>
								</tr>
								<tr class="h20">
									<td><%=iname%></td>
									<td><%=cust_Id%></td>
									<td><%=sPhone%></td>
									<td><%=cust_addr%></td>
									<td><%=FncBrandDBName(BRAND_ID)%></td>
									<td><%=a_branch_name%></td>
									<td><%=a_phone%></td>
									<td>?</td>
								</tr>
							</table>
						</div>
					</div>
		
					<div class="db db_6">
						<div class="txt_t">
							<b>상담내역</b>
						</div>
						<div class="ta ta_1">
							<table>
								<tr>
									<th>No</th>
									<th>상담자</th>
									<th>상담내용</th>
									<th>상담일시</th>
									<th>처리</th>
								</tr>
<%
	Sql = "select * from BBQ_HOME_OLD.DBO.t_Cms_Log with(nolock) where orderid='"& OID &"' order by seq desc"
	Set oRs = conn.Execute(Sql)
	If Not oRs.Eof Then 
		num = 1
		Do While Not oRs.Eof
			If oRs("cms_type") = "INFO" Then
				sResult = "<span style='color:blue'>안내</span>"
			elseIf oRs("cms_type") = "CANC" Then
				sResult = "<span style='color:red'>취소</span>"
			Else
				sResult = "<span style='color:black'>정보</span>"
			End If
%>
								<tr>
									<td><%=num%></td>
									<td><%=oRs("username")%></td>
									<td class="tl"><%=oRs("note1")%></td>
									<td><%=oRs("regdate")%></td>
									<td><%=sResult%></td>
								</tr>
<%
			oRs.MoveNext
			num = num + 1
		Loop
	End If 
	oRs.close
	Set oRs = Nothing 
%>
							</table>
						</div>
					</div>
				</div>
				<div class="list_foot">
					<div style="display:inline-block;float:right;">
						<button type="button" class="btn_red125" onClick="AddCMS()">상담하기</button>
					</div>
				</div>
			</div>
		</div>