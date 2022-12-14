<!-- #include virtual="/inc/config.asp" -->
<%
	CUR_PAGE_CODE = "G"
	CUR_PAGE_SUBCODE = ""
%>
<!-- #include virtual="/inc/admin_check.asp" -->
<%
	USE		= InjRequest("USE")
	SM		= InjRequest("SM")
	SW		= InjRequest("SW")
	LNUM	= InjRequest("LNUM")
	If FncIsBlank(LNUM) Then LNUM = 10
	DetailN = "USE="& USE &"&SM="& SM &"&SW="& SW
	Detail = "&LNUM="& LNUM & "&"& DetailN

	strCPNIDS = "10005|10008|10009|10010|10011|10012|10031"
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<!-- #include virtual="/inc/head.asp" -->
<script>
function Coupon_Detail_pop(CPNID, PIN){
	$.ajax({
		async: true,
		type: "POST",
		url: "coupon_detail_partner_div.asp",
		data: {"CPNID":CPNID,"PIN":PIN},
		cache: false,
		dataType: "html",
		success: function (data) {
			if ( data.replace(/^\s\s*/, '').replace(/\s\s*$/, '').length == 0 ) {
			}else{
				$("#coupon_detail_div").html(data);
				wrapWindowByMask();
			}
		},
		error: function(data, status, err) {
			alert(err + '서버와의 통신이 실패했습니다.');
		}
	});
}
function funcExcelDown()
{
	document.getElementById("ifrExcel").src = "coupon_ebay_pin_excel.asp?strCPNIDS=<%=strCPNIDS%>";
}
</script>
</head>
<body>
    <div class="wrap">
<!-- #include virtual="/inc/header.asp" -->
<!-- #include virtual="/inc/header_nav.asp" -->
		<div class="board_top">
			<div class="route"> 
				<span><p>관리자</p> > <p>쿠폰관리</p> > <p>E-쿠폰관리</p></span>
			</div>
		</div>
	</div>
	<!--//GNB-->
</div>
<!--//NAV-->
        <div class="content">
            <div class="section section_couponlist">
				<form id="searchfrm" name="searchfrm" method="get">
				<input type="hidden" name="LNUM" value="<%=LNUM%>">
				<div class="section_couponlist_sel">
					<table>
						<tbody>
							<tr>
								<th>
									<ul>
										<li><label><input type="radio" name="boardlist" onClick="document.location.href='coupon_pin.asp'">멤버십 쿠폰</label></li>
										<li><label><input type="radio" name="boardlist" onClick="document.location.href='coupon_prm.asp'">프로모션 쿠폰</label></li>
										<li><label><input type="radio" name="boardlist" onClick="document.location.href='coupon_money.asp'">금액권</label></li>
										<li><label><input type="radio" name="boardlist" onClick="document.location.href='coupon_ebay_pin.asp'" checked>이베이 쿠폰</label></li>
										<li><label><input type="radio" name="boardlist" onClick="document.location.href='coupon_partner.asp'">거래처 쿠폰</label></li>
										<li><label><input type="radio" name="boardlist" onClick="document.location.href='coupon_search.asp'">쿠폰조회</label></li>
									</ul>
								</th>
							</tr>
							<tr>
								<th>
									<ul>
										<div class="couponlist_search">
											<div>
												<span>사용여부:</span>
												<select name="USE" id="USE">
													<option value=""<%If USE="" Then%> selected<%End If%>>전체</option>
													<option value="Y"<%If USE="Y" Then%> selected<%End If%>>정상사용</option>
													<option value="N"<%If USE="N" Then%> selected<%End If%>>미사용</option>
												</select>
												<select name="SM" id="SM">
													<option value="C"<%If SM="C" Then%> selected<%End If%>>쿠폰코드</option>
													<option value="P"<%If SM="P" Then%> selected<%End If%>>핀번호</option>
												</select>
												<input type="text" name="SW" value="<%=SW%>">
												<input type="submit" value="검색" class="btn_white">
											</div>
										</div>
									</ul>
								</th>
							</tr>
						</tbody>
					</table>
				</div>
				</form>
<%
	's_Common_PINList_Partner_CTE
	num_per_page	= LNUM	'페이지당 보여질 갯수
	page_per_block	= 10	'이동블럭

	page = InjRequest("page")
	If page = "" Then page = 1

	SqlWhere = " WHERE T1.CPNID IN ('"& Replace(strCPNIDS, "|","','") &"') "
	If Not FncIsBlank(USE) Then	
		If USE = "Y" Then 
			SqlWhere = SqlWhere & " AND T1.STATUS='9' "
		Else
			SqlWhere = SqlWhere & " AND T1.STATUS='1' "
		End If
	End If
	If Not FncIsBlank(SW) Then
		If SM = "C" Then 
			SqlWhere = SqlWhere & " AND T1.CPNID='"& SW &"' "
		ElseIf SM = "P" Then 
			SqlWhere = SqlWhere & " AND T1.PIN='"& SW &"' "
		End If
	End If 

	Sql = "Select COUNT(*) CNT FROM "& BBQHOME_DB &".DBO.T_CPN_MST T1 WITH(NOLOCK) INNER JOIN "& BBQHOME_DB &".DBO.T_CPN T2 WITH(NOLOCK) ON T2.CPNID = T1.CPNID " & SqlWhere
	Set Trs = conn.Execute(Sql)
	total_num = Trs("CNT")
	Trs.close
	Set Trs = Nothing 

	If total_num = 0 Then
		first  = 1
	Else
		first  = num_per_page*(page-1)
	End If 

	total_page	= ceil(total_num / num_per_page)
	total_block	= ceil(total_page / page_per_block)
	block       = ceil(page / page_per_block)
	first_page  = (block-1) * page_per_block+1
	last_page   = block * page_per_block

%>
				<div class="list">
					<div class="list_top">
						<div class="list_total">
							<span>Total:<p> <%=total_num%>건</p></span>
						</div>
						<div class="list_num">
							<select name="LNUM" id="LNUM" onChange="document.location.href='?<%=DetailN%>&LNUM='+this.value">
								<option value="10"<%If LNUM="10" Then%> selected<%End If%>>10</option>
								<option value="20"<%If LNUM="20" Then%> selected<%End If%>>20</option>
								<option value="50"<%If LNUM="50" Then%> selected<%End If%>>50</option>
								<option value="100"<%If LNUM="100" Then%> selected<%End If%>>100</option>
							</select>
						</div>
					</div>
					<div class="list_content">
						<table style="width:100%;">
							<tr>
								<th>쿠폰코드</th>
								<th>쿠폰명</th>
								<th>핀번호</th>
								<th>사용여부</th>
								<th>사용일시</th>
								<th>회원ID</th>
								<th>매장코드</th>
								<th>매장</th>
							</tr>
<%
	If total_num > 0 Then 
		STARTNUM = ( (page-1) * num_per_page) + 1
		ENDNUM = ( page * num_per_page)
		Sql = "	SELECT "
		Sql = Sql & "	T1.ROW_NO, T1.CPNID, T1.CPNNAME, T1.PINID, T1.PIN, T1.CPNTYPE, T1.USESDATE, T1.USEEDATE, "& BBQHOME_DB &".DBO.FN_COUPON_STATUS(T1.PIN) AS STATUS, T1.PUBDATE AS REGDATE, "
		Sql = Sql & "	T1.USEDATE, T1.OWNERID, "	' -- ISNULL(T4.NAME, '&nbsp;') AS dbo.ecl_decrypt(USERNAME), T4.HP1 as dbo.ecl_decrypt(HP1), T4.HP2 as dbo.ecl_decrypt(HP2), T4.HP3 as dbo.ecl_decrypt(HP3),
		Sql = Sql & "	T1.BRANCH_ID, T2.BRANCH_NAME "
		Sql = Sql & " FROM ( "
		Sql = Sql & "	SELECT "
		Sql = Sql & "		RANK() OVER(ORDER BY ISNULL(T1.USEDATE,'2060-12-31'), CASE WHEN T1.STATUS = 8 THEN 999 ELSE T1.STATUS END, PINID) ROW_NO, "
		Sql = Sql & "		T1.CPNID, T2.CPNNAME, T1.PINID, T1.PIN, T1.CPNTYPE, T1.USESDATE, T1.USEEDATE, T1.STATUS, T1.PUBDATE, T1.USEDATE, T1.OWNERID, T1.U_CD_PARTNER AS BRANCH_ID "
		Sql = Sql & "	FROM "& BBQHOME_DB &".DBO.T_CPN_MST T1 WITH (NOLOCK) INNER JOIN "& BBQHOME_DB &".DBO.T_CPN T2 WITH (NOLOCK) ON T2.CPNID = T1.CPNID "
		Sql = Sql & SqlWhere
		Sql = Sql & ") T1 "
		Sql = Sql & " LEFT JOIN BT_BRANCH T2 WITH (NOLOCK) ON T2.BRAND_CODE ='01' AND T2.BRANCH_ID = T1.BRANCH_ID "
'		Sql = Sql & " LEFT JOIN BT_MEMBER T4 WITH (NOLOCK) ON T4.MEMBER_ID = T1.OWNERID "
		Sql = Sql & " WHERE ROW_NO BETWEEN  "& STARTNUM &" AND "& ENDNUM &" "
		Sql = Sql & " ORDER BY ROW_NO "

		Set Rlist = conn.Execute(Sql)
		If Not Rlist.Eof Then 
			num	= total_num - first
			Do While Not Rlist.Eof
				CPNID		= Rlist("CPNID")
				CPNNAME		= Rlist("CPNNAME")
				PINID		= Rlist("PINID")
				PIN			= Rlist("PIN")
				CPNTYPE		= Rlist("CPNTYPE")
				USESDATE	= Rlist("USESDATE")
				USEEDATE	= Rlist("USEEDATE")
				STATUS		= Rlist("STATUS")
				REGDATE		= Rlist("REGDATE")
				USEDATE		= Rlist("USEDATE")
				OWNERID		= Rlist("OWNERID")
				BRANCH_ID	= Rlist("BRANCH_ID")
				BRANCH_NAME	= Rlist("BRANCH_NAME")

				IF STATUS="1" THEN
					STATUS_TXT="미사용"
				ELSEIF STATUS="7" THEN
					STATUS_TXT="기한만료"
				ELSEIF STATUS="8" THEN
					STATUS_TXT="사용불가"
				ELSEIF STATUS="9" THEN
					STATUS_TXT="정상사용"
				ELSE
					STATUS_TXT=""
				END If
%>
							<tr>
								<td><span><%=CPNID%></span></td>
								<td><span><%=CPNNAME%></span></td>
								<td><span><a href="javascript:;" onClick="Coupon_Detail_pop('<%=CPNID%>','<%=PIN%>');"><%=PIN%></a></span></td>
								<td><span><%=STATUS_TXT%></span></td>
								<td><span><%=USEDATE%></span></td>
								<td><span><%=OWNERID%></span></td>
								<td><span><%=BRANCH_ID%></span></td>
								<td><span><%=BRANCH_NAME%></span></td>
							</tr>
<%
				num = num - 1
				Rlist.MoveNext
			Loop
		End If
		Rlist.Close
		Set Rlist = Nothing 
	End If 
%>
						</table>
					</div>
					<div class="list_foot">
<!-- #include virtual="/inc/paging.asp" -->
                        <div style="display:inline-block;float:right;">
                            <button class="btn_red125" onClick="funcExcelDown()">엑셀저장</button>
                        </div>
					</div>
				</div>
			</div>
		</div>
<iframe src="" name="ifrExcel" id="ifrExcel" width=700 height=300 style="display:none"></iframe>
<!-- #include virtual="/inc/footer.asp" -->
    </div>
</body>
</html>