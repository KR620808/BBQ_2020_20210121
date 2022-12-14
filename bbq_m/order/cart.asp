<!--#include virtual="/api/include/utf8.asp"-->
<script type="text/javascript">
	if(sessionStorage.getItem("M_1695_0_") || sessionStorage.getItem("M_1696_0_")){
		sessionStorage.setItem("ss_order_type", "R");
	}
</script>
<%

	order_type = GetReqStr("order_type","")
	branch_id = GetReqStr("branch_id","")
	branch_data = GetReqStr("branch_data","")
	addr_idx = GetReqStr("addr_idx","")
	addr_data = GetReqStr("addr_data","")

	cancel_idx = GetReqStr("cancel_idx","")

	If order_type = "D" Then
		If addr_idx <> "" And addr_data <> "" Then
			Set aJson = JSON.Parse(addr_data)

			addr_idx = aJson.addr_idx
			address = aJson.address_main&" "&aJson.address_detail
			Set aJson = Nothing
		Else
			If CheckLogin() Then
				If addr_idx = "" Then addr_idx = 0

				Set aCmd = Server.CreateObject("ADODB.Command")

				With aCmd
					.ActiveConnection = dbconn
					.NamedParameters = True
					.CommandType = adCmdStoredProc
					.CommandText = "bp_member_addr_select"

					.Parameters.Append .CreateParameter("@addr_idx", adInteger, adParamInput, , addr_idx)
					.Parameters.Append .CreateParameter("@member_idno", adVarChar, adParamInput, 50, Session("userIdNo"))
					If addr_idx = 0 Then
						.Parameters.Append .CreateParameter("@mode", adVarChar, adParamInput, 10, "MAIN")
					Else
						.Parameters.Append .CreateParameter("@mode", adVarChar, adParamInput, 10, "ONE")
					End If

					Set aRs = .Execute
				End With
				Set aCmd = Nothing

				If Not (aRs.BOF Or aRs.EOF) Then
					addr_idx = aRs("addr_idx")
					address = aRs("address_main")&" "&aRs("address_detail")

					addr_data = AddressToJson(aRs)
				End If

				Set aRs = Nothing

			End If
		End If

		If branch_data <> "" Then
			Set bJson = JSON.Parse(branch_data)
			branch_id = bJson.branch_id
			branch_name = bJson.branch_name
			branch_tel = bJson.branch_tel
			Set bJson = Nothing
		End If
	ElseIf order_type = "P" Then
		If branch_id <> "" And branch_data <> "" Then
			Set bJson = JSON.Parse(branch_data)
			branch_name = bJson.branch_name
			branch_tel = bJson.branch_tel
			address = bJson.branch_address
			Set bJson = Nothing
		End If
	ElseIf order_type = "R" Then
		branch_name = "??????"
		branch_tel = "??????"
		address = "??????"
	End If

	ShowOrderType = False
	If (order_type = "D" AND addr_data = "") Or (order_type = "P" And branch_data = "") Then
		ShowOrderType = True
	End If
%>

<!doctype html>
<html lang="ko">

<head>
<% Dim FB_script : FB_script = "fbq('track', 'AddToCart');" %>
<% Dim kakao_script : kakao_script = " kakaoPixel('1188504223027052596').viewCart(); " %>
<!--#include virtual="/includes/top.asp"-->


</head>

<body>

<div class="wrapper">

	<%
		PageTitle = "????????????"
	%>

	<!--#include virtual="/includes/header.asp"-->

	<!-- Container -->
	<div class="container">

		<!-- Aside -->
		<!--#include virtual="/includes/aside.asp"-->
		<!--// Aside -->
			
		<!-- Content -->
		<article class="content inbox1000_2">

			<!-- ???????????? -->
			<!--#include virtual="/includes/address.asp"-->
			<!-- // ???????????? -->

			<form id="cart_form" name="cart_form" method="post" action="payment.asp">
				<input type="hidden" name="order_type" id="order_type" value="<%=order_type%>">
				<input type="hidden" name="branch_id" id="branch_id" value="<%=branch_id%>">
				<input type="hidden" name="branch_data" id="branch_data" value='<%=branch_data%>'>
				<input type="hidden" name="addr_idx" id="addr_idx" value="<%=addr_idx%>">
				<input type="hidden" name="cart_value">
				<input type="hidden" name="cart_ec_list">
				<input type="hidden" name="addr_data" id="addr_data" value='<%=addr_data%>'>
				<input type="hidden" name="spent_time" id="spent_time">
				<input type="hidden" name="pin_save" id="pin_save">
				<input type="hidden" name="h_code" id="h_code"> <!-- ????????? ?????? ??? ?????? -->
			</form>

			<input type="hidden" id="CART_IN_PRODIDX">

			<script type="text/javascript">
			    $(document).ready(function (){
                    localStorage.setItem("Adult_yn", "N");
            	})
				$('#order_type').val(sessionStorage.getItem("ss_order_type"));
				$('#branch_id').val(sessionStorage.getItem("ss_branch_id"));
				$('#branch_data').val(sessionStorage.getItem("ss_branch_data"));
				$('#addr_idx').val(sessionStorage.getItem("ss_addr_idx"));
				$('#addr_data').val(sessionStorage.getItem("ss_addr_data"));
				$('#spent_time').val(sessionStorage.getItem("ss_spent_time"));
				$('#pin_save').val(sessionStorage.getItem("ss_pin_save"));
			</script>

<!--
			<div class="inbox1000" style="margin-top:20px">
				<span style="color:red;weight:bold">??? ???????????? ????????? ?????? ????????? ?????? ??? ?????? ??????????????? ?????? ??????????????? ????????????.</span>
			</div>
-->
			<%
			Dim aEcCmd, aEcRs

			Set aEcCmd = Server.CreateObject("ADODB.Command")

			With aEcCmd
				.ActiveConnection = dbconn
				.NamedParameters = True
				.CommandType = adCmdStoredProc
				.CommandText = "bt_member_coupon_select"
				.Parameters.Append .CreateParameter("@member_idno", adVarChar, adParamInput, 100, Session("userIdNo"))
				.Parameters.Append .CreateParameter("@mode", adVarChar, adParamInput, 20, "LIST")
				.Parameters.Append .CreateParameter("@totalCount", adInteger, adParamOutput)

				Set aEcRs = .Execute
			End With
			Set aEcCmd = Nothing   

			If Not (aEcRs.BOF Or aEcRs.EOF) Then
			%>
				<input type="hidden" id="blnMyECoupon" name="blnMyECoupon" value="Y" />
			<%
			end if 
			Set aEcRs = Nothing   
			%>
			<div id="divSaveMenu" class="page_title inbox1000">
				<p>????????????</p>
<!--				??????-->
				<span class="btn-del" id="cart_all_del" onclick="cart_all_clear_del()" style="cursor:pointer">????????????</span>
			</div>


			<!-- ???????????? ????????? -->
			<section class="section_orderDetail inbox1000">

				<div id="cart_list"></div><!-- /common/js/function.js -->

				<div class="alignC">
					<button type="button" onclick="goMenuList();" class="btn btn_middle btn-gray btn_pluse"><img src="/images/order/icon_pluse.png"> ??? ????????? ??????</button>
				</div>


				<!-- ????????????:functions.js -->
				<div id="recom_div" class="recom"></div>
				<!-- ???????????? -->
				
				
				
				<!-- ???????????????-->
				<script src="/common/js/jquery.min.js"></script>
				<script src="/common/js/jquery.beefup.min.js"></script>
				<div class="sidemenu_wrap">
					<div class="page_title">
						<p>????????? ??????(??????)</p>
					</div>

					<div class="sidemenu_wrap">

						<%
							Set aCmd = Server.CreateObject("ADODB.Command")

							With aCmd
								.ActiveConnection = dbconn
								.NamedParameters = True
								.CommandType = adCmdStoredProc
								.CommandText = "bp_sidemenu_select"

								Set aRs = .Execute
							End With

							Set aCmd = Nothing

							Dim category_name : category_name = ""

							If Not (aRs.BOF Or aRs.EOF) Then
								aRs.MoveFirst
								Do Until aRs.EOF
									thumb_file_path = aRs("thumb_file_path")
									thumb_file_name = aRs("thumb_file_name")

									If aRs("category_name") <> category_name Then
										If category_name <> "" Then
						%>
												</ul>
											</div>
										</article>
						<%
										End If
						%>
										<article class="beefup example">
											<h4 class="beefup__head"><%=aRs("category_name")%></h4>
											<div class="beefup__body">
												<ul class="sidemenu_list">

						<%
										category_name = aRs("category_name")
									End If
						%>
													<li>
														<ul  class="sidemenu_con">
															<li><%=DeleteHTML(aRs("menu_name"))%></li>
															<li>+ <%=FormatNumber(aRs("menu_price"),0)%>???</li>
															<li><a href="javascript: goAddCart_side('M_<%=aRs("menu_idx")%>_0', 'M$$<%=aRs("menu_idx")%>$$0$$<%=aRs("menu_price")%>$$<%=aRs("menu_name")%>$$<%=SERVER_IMGPATH&thumb_file_path&thumb_file_name%>'); " class="btn_sidemenu_add">??????</a></li>
														</ul>
													</li>

						<%
									aRs.MoveNext
								Loop
						%>
												</ul>
											</div>
										</article>
						<%
							End If

							Set aRs = Nothing
						%>

						<script>
							$(function() {
								// Default
								$('.example').beefup();
							});
						</script>
					</div>

				</div>
				<!-- // ??????????????? -->			
				
				
				
				
				
				
				<ul class="cart_total">
					<li>????????????</li>
					<li  id="total_amount">0<span>???</span></li>
					<input type="hidden" id="total_amount_h" />
				</ul>

				<%If CheckLogin() Then%><% else %><div class="cart_wait"><span>??????!</span> ????????? ??? ?????? ????????? ???????????? ?????????!!</div><% end if %>
				
				<div class="cart_btn">
					<%If CheckLogin() Then%><% else %><button type="button"  onclick="openLogin('mobile');"  class="btn btn-white btn_big btn-cart_login">?????????</button><%End If%>

<!-- 
					<div id="pickup-wrap_div" class="pickup-wrap pickup-wrap2 mar-t30 " style="display:none">
						<span class="txt">????????????????????????</span>
						<div class="orderType-radio orderType-radio2">
							<label class="ui-radio2">
								<input type="radio" name="after" value="30" id="after30" onclick="after_control()" checked="checked">
								<span></span> 30??? ???
							</label>
							<label class="ui-radio2">
								<input type="radio" name="after" value="45" id="after40" onclick="after_control()">
								<span></span> 45??? ???
							</label>
							<label class="ui-radio2">
								<input type="radio" name="after" value="60" id="after50" onclick="after_control()">
								<span></span> 60??? ???
							</label>
							<label class="ui-radio2">
								<input type="radio" name="after" value="90" id="after90" onclick="after_control()">
								<span></span> 90??? ???
							</label>
						</div>
						<div class="txt-basic inner mar-t20">
							?????? ??????????????? 15??? ?????????.
						</div>
					</div>

					<script type="text/javascript">
						if (sessionStorage.getItem("ss_order_type") == "P") {
							$('#pickup-wrap_div').show(0)
						}
					</script>
 -->

					<button type="button"  onclick="goOrder()"  class="btn btn-red btn_big btn-cart_order">????????????</button>
				</div>
			</section>
			<!-- //???????????? ????????? -->

			<!-- Layer Popup : ????????? ?????? -->
			<div id="LP_orderShipping1" class="lp-wrapper lp_orderShipping1">
				<!-- LP Header -->
				<div class="lp-header">
					<h2>?????? ?????? ??????</h2>
				</div>
				<!--// LP Header -->
				<!-- LP Container -->
				<div class="lp-container">
					<!-- LP Content -->
					<div class="lp-content">
						<form action="">

						</form>
					</div>
					<!--// LP Content -->
				</div>
				<!--// LP Container -->
				<button type="button" class="btn btn_lp_close"><span>??????????????? ??????</span></button>
			</div>
			<!--// Layer Popup -->

			<!-- Layer Popup : ????????? ?????? - ????????????(????????????) -->
			<div id="LP_orderShipping2" class="lp-wrapper lp_shopSearch2">
				<!-- LP Header -->
				<div class="lp-header">
					<h2>?????? ??????</h2>
				</div>
				<!--// LP Header -->
				<!-- LP Container -->
				<div class="lp-container">
					<!-- LP Content -->
					<div class="lp-content">
						<form action="">

						</form>
					</div>
					<!--// LP Content -->
				</div>
				<!--// LP Container -->
				<button type="button" class="btn btn_lp_close"><span>??????????????? ??????</span></button>
			</div>
			<!--// Layer Popup -->
					
				<!-- 
				</div>
				<div class="payment">
					<div class="addmenu">
					</div>
					<div class="calc">
						<div class="top">
							<dl>
								<dt>????????????</dt>
								<dd id="sc_item_amount">0???</dd>
							</dl>
							<dl>
								<dt>????????????</dt>
								<dd id="sc_side_amount">0???</dd>
							</dl>
						</div>
						<div class="bot">
							<dl>
								<dt>????????????</dt>
								<dd id="sc_pay_amount">0???</dd>
							</dl>
						</div>
					</div>
				</div>
				<button type="button" class="btn_menu_close" onclick="javascript:closeSideChange();">??????</button>

			</div>
			-->

			<!-- //?????? ?????? -->

			<!-- ???????????? ?????? -->
			<div class="cart-fix on display-n" style="transition:0s;">
				<button type="button" class="btn btn-md btn-red btn_menu_cart" onclick="javascript:sideChangeApply();">???????????? ??????</button>
			</div>
			<!-- //???????????? ?????? -->



		</article>
		<!--// Content -->

	</div>
	<!--// Container -->

<div id="LP_cartCoupon" class="lp-wrapper lp_cartCoupon" style="display: none">
<article id="LP_eCoupon" class="eCoupon_wrap">
	<!-- e?????? ????????? -->
	<section class="section section_couponUseOk">
		
		<!-- e?????? ?????? -->
		<section class="eCoupon_wrap">
			<h3>????????? ?????????  ?????????<br>???????????? ?????????.</h3>
			<ul class="area">
				<li><input type="text" id="txtPIN" name="txtPIN" placeholder="????????? ????????? ?????? ??????" class="w-70p" autocomplete="off" style="margin-right:2%;" maxlength="12"><button type="button" onclick='javascript:eCouponUse("CA");' class="btn-sm btn-black w-15p">??????</button></li>
			</ul>
		</section>
		<!-- //e?????? ?????? -->

		<!-- <div class="couponUseOk_wrap"> -->
		<div class="couponUseOk">
		<%
			Dim aCmd, aRs

			Set aCmd = Server.CreateObject("ADODB.Command")

			With aCmd
				.ActiveConnection = dbconn
				.NamedParameters = True
				.CommandType = adCmdStoredProc
				.CommandText = "bt_member_coupon_select"
				.Parameters.Append .CreateParameter("@member_idno", adVarChar, adParamInput, 100, Session("userIdNo"))
				.Parameters.Append .CreateParameter("@mode", adVarChar, adParamInput, 20, "LIST")
				.Parameters.Append .CreateParameter("@totalCount", adInteger, adParamOutput)

				Set aRs = .Execute
			End With
			Set aCmd = Nothing   

			dim idxEcoupon : idxEcoupon = 0 
			If Not (aRs.BOF Or aRs.EOF) Then    
				aRs.MoveFirst  

				Do Until aRs.EOF  
					idxEcoupon = idxEcoupon + 1
			%>
            <div class="divCouponItemM"> 
				<div class="coupon">
					<!--
					<div class="tit div-table">
						<ul class="tr">
							<li class="td device"><span class="ico-branch red">???????????????</span></li>
							<li class="td day"></li>
						</ul>
					</div>
					-->
					<dl class="info">
						<label class='checkbox'>
						<dt><input type="checkbox" name="chkEcoupon" id="chkEcoupon<%=idxEcoupon%>" value="<%=aRs("c_code")%>" /> <b><%=aRs("c_title")%></b></dt>
						<dd>
							???&nbsp;&nbsp;&nbsp;&nbsp;??? : <%=aRs("c_code")%><br/>
							???&nbsp;&nbsp;&nbsp;&nbsp;??? : <%=FormatNumber(aRs("CPN_PRICE"), 0)%><br/>
							???????????? : <%=aRs("USESDATE")%> ~ <%=aRs("USEEDATE")%>
						</dd>
						</label>
					</dl>
					<!--<dl class="coupon_list_delete"><a href='javascript:eCoupon_Check_GoCart("N", "<%=aRs("c_code")%>");' class="btn btn-red btn_middle">????????????</a></dl>
					<dl class="coupon_list_use"><a href='javascript:eCoupon_Check_GoCart("N", "<%=aRs("c_code")%>");' class="btn btn-red btn_middle">??????</a></dl>
					<dl class="coupon_list_delete"><a href="javascript:eCoupon_del_plus('<%=aRs("c_code")%>')"><img src="/images/mypage/ico_delete.png">??????</a></dl>-->
				</div>
				<div class="txt">
					<br/> 
				</div>                        
			</div>
		<%
					aRs.MoveNext
				Loop
			End If
			Set aRs = Nothing                
		%>	
			<div id="divCouponUse">
				<button type="button" onclick='javascript:eCouponUse("CU");' class="btn btn_middle btn-red">????????????</button>
				<div class="txt">
					- ??? ????????? ?????? ????????????
				</div>
			</div>
		</div>
	</section>
</article>   
	<button type="button" class="btn btn_lp_close" onclick="lpClose('.lp_cartCoupon')"><span>??????????????? ??????</span></button>
	<!-- //???????????? e?????? -->
</div>

<!-- Layer Popup : ????????? ?????? -->
<div id="LP_addShipping" class="lp-wrapper lp_addShipping" style="display:none;">
	<form id="form_addr" name="form_addr" method="post" onsubmit="return false;">
		<input type="hidden" name="addr_idx" value="">
		<input type="hidden" name="mode" value="I">
		<input type="hidden" name="addr_type" value="">
		<input type="hidden" name="address_jibun" value="">
		<input type="hidden" name="address_road" value="">
		<input type="hidden" name="sido" value="">
		<input type="hidden" name="sigungu" value="">
		<input type="hidden" name="sigungu_code" value="">
		<input type="hidden" name="roadname_code" value="">
		<input type="hidden" name="b_name" value="">
		<input type="hidden" name="b_code" value="">
		<input type="hidden" name="mobile" value="">
	<!-- LP Header -->
	<div class="lp-header">
		<h2>????????? ??????</h2>
	</div>
	<!--// LP Header -->
	<!-- LP Container -->
	<div class="lp-container">
		<!-- LP Content -->
		<div class="lp-content">
			<form action="">
			</form>
		</div>
		<!--// LP Content -->
	</div>
	<!--// LP Container -->
	<button type="button" class="btn btn_lp_close"><span>??????????????? ??????</span></button>
</div>
<!--// Layer Popup -->





<% If Request.ServerVariables("HTTP_HOST") = "bbq.fuzewire.com:8010" Then %>
	<script src="http://dmaps.daum.net/map_js_init/postcode.v2.js?autoload=false"></script>
<% Else %>
	<script src="https://ssl.daumcdn.net/dmaps/map_js_init/postcode.v2.js?autoload=false"></script>
<% End If %>

<% If instr(Request.ServerVariables("HTTP_USER_AGENT"), "bbqAOS") > 0 Then %>

	<script>
		// ???????????? ?????? ?????? ????????? ?????? element
		var element_wrap = document.getElementById('wrap_daum');

		function foldDaumPostcode() {
			// iframe??? ?????? element??? ???????????? ??????.
					$('#viewport').removeAttr('content','minimum-scale=1.0, width=750, maximum-scale=1.0, user-scalable=no');
					$('#viewport').attr('content','width=750, maximum-scale=1.0, user-scalable=no');
			document.getElementById('wrap_daum').style.display = 'none';
		}

		function showPostcode() {
			// ?????? scroll ????????? ??????????????????.
			var currentScroll = Math.max(document.body.scrollTop, document.documentElement.scrollTop);
		daum.postcode.load(function(){
			new daum.Postcode({
				oncomplete: function(data) {
					$("#address_main").val(data.userSelectedType == "J"? data.jibunAddress: data.roadAddress);

					$("#form_addr input[name=zip_code]").val(data.zonecode);
					$("#form_addr input[name=addr_type]").val(data.userSelectedType);
					$("#form_addr input[name=address_jibun]").val(data.jibunAddress);
					$("#form_addr input[name=address_road]").val(data.roadAddress);
					$("#form_addr input[name=sido]").val(data.sido);
					$("#form_addr input[name=sigungu]").val(data.sigungu);
					$("#form_addr input[name=sigungu_code]").val(data.sigunguCode);
					$("#form_addr input[name=roadname_code]").val(data.roadnameCode);
					$("#form_addr input[name=b_name]").val(data.bname);
					$("#form_addr input[name=b_code]").val(data.bcode);
					$('#viewport').removeAttr('content','minimum-scale=1.0, width=750, maximum-scale=1.0, user-scalable=no');
					$('#viewport').attr('content','width=750, maximum-scale=1.0, user-scalable=no');
					document.getElementById('wrap_daum').style.display = 'none';
				},
				// ???????????? ?????? ?????? ????????? ?????????????????? ????????? ????????? ???????????? ??????. iframe??? ?????? element??? ???????????? ????????????.
				onresize : function(size) {
					document.getElementById('wrap_daum').style.height = size.height+'px';
				},
				width : '100%',
				height : '100%'
			}).embed(document.getElementById('wrap_daum'));

			});
			// iframe??? ?????? element??? ????????? ??????.
					document.getElementById('wrap_daum').style.display = 'block';
					$('#layer').css('z-index','999');
					$('#viewport').attr('content','minimum-scale=1.0, width=750, maximum-scale=1.0, user-scalable=no');
		}
	</script>

<% Else %>

	<script type="text/javascript">

		function showPostcode() {
			
			daum.postcode.load(function(){
				new daum.Postcode({
					oncomplete: function(data) {
						$("#address_main").val(data.userSelectedType == "J"? data.jibunAddress: data.roadAddress);

						$("#form_addr input[name=zip_code]").val(data.zonecode);
						$("#form_addr input[name=addr_type]").val(data.userSelectedType);
						$("#form_addr input[name=address_jibun]").val(data.jibunAddress);
						$("#form_addr input[name=address_road]").val(data.roadAddress);
						$("#form_addr input[name=sido]").val(data.sido);
						$("#form_addr input[name=sigungu]").val(data.sigungu);
						$("#form_addr input[name=sigungu_code]").val(data.sigunguCode);
						$("#form_addr input[name=roadname_code]").val(data.roadnameCode);
						$("#form_addr input[name=b_name]").val(data.bname);
						$("#form_addr input[name=b_code]").val(data.bcode);
					}
				}).open();
			});
		}

	</script>

<% End If %>

<script type="text/javascript">
	var delivery_amt = 0;
	var cartPage = "cart";
	$(function(){
		if($("#addr_data").val() != "" && $("#branch_data").val() == "") {
			$.ajax({
				method: "post",
				url: "/api/ajax/ajax_getShopNew.asp",
				data:{dta:$("#addr_data").val()},
				dataType: "json",
				success: function(res) {
					if(res.result == "0000") {
						if(res.online_status != "Y") {
							showAlertMsg({msg:"???????????? ????????? ?????? ????????? ????????? ??????????????? ????????? ?????? ????????????."});
							$("#branch_id").val("");
							$("#branch_data").val("");

							$("#branch_name").text("-");
							$("#branch_tel").text("");
						} else {
							$("#branch_id").val(res.branch_id);
							$("#branch_data").val(JSON.stringify(res));

							$("#branch_name").text(res.branch_name);
							$("#branch_tel").text("("+res.branch_tel+")");
						}
					} else {
						showAlertMsg({msg:res.message});
						$("#branch_id").val("");
						$("#branch_data").val("");

						$("#branch_name").text("-");
						$("#branch_tel").text("");
					}
				},
				error: function(xhr){
					showAlertMsg({msg:"??????????????? ????????? ????????????."});
					$("#branch_id").val("");
					$("#branch_data").val("");

					$("#branch_name").text("-");
					$("#branch_tel").text("");
				}
			});
		}
		$("#delivery_fee").text(numberWithCommas(delivery_amt)+"???");

		getView();

		if($("#addr_idx").val() == "" && getTempAddress() != null) {
			setTempAddress();
		}

		// getMenuRecom();

<%
	If ShowOrderType Then
%>
		lpOpen(".lp_orderShipping");
<%
	End If

	If cancel_idx <> "" And CheckLogin() Then
%>
	$.ajax({
		type: "post",
		url: "/order/order_membership_cancel.asp",
		data: {order_idx: "<%=cancel_idx%>"},
		dataType: "json",
		success: function(res) {
			if(res.result == 0) {
				showAlertMsg({msg:"?????????????????? ?????????????????????."});
			} else {
				//showAlertMsg({msg:"?????????????????? ???????????? ???????????????."});
			}
		},
		error: function(xhr) {
			showAlertMsg({msg:"????????? ????????? ??????????????? ???????????? ???????????????."});
		}
	});
<%
	End If
%>

<% If instr(Request.ServerVariables("HTTP_USER_AGENT"), "bbqAOS") > 0 Or instr(Request.ServerVariables("HTTP_USER_AGENT"), "bbqiOS") > 0 Then %>
		//alert("-??? ??????????????? ???????????? ??????-\n\n???????????? ????????????\n????????? ?????? ??????????????????.\nhttps://m.bbq.co.kr/\n????????? ????????? ?????? ???????????????.");
		//return;
<% End If %>
	});

	function goOrder() {
		<% If instr(Request.ServerVariables("HTTP_USER_AGENT"), "bbqAAOS") > 0 Then %>
			alert("??? ?????? ??????????????? ?????? ??? ?????????.\n\n??????????????? ???????????????,\nm.bbq.co.kr??? ???????????? ????????????.\n\n????????? ????????? ?????? ???????????????.");
			//return;
		<% End If %>
//		switch($("#order_type").val()) {
//			case "D":
//				if($("#addr_idx").val() == "") {
//					showAlertMsg({msg:"??????????????? ???????????????."});
//					return false;
//				}
//
//				if($("#branch_id").val() == "") {
//					showAlertMsg({msg:"??????????????? ????????? ????????????."});
//					return false;
//				}
//			break;
//			case "P":
//				if($("#branch_id").val() == "") {
//					showAlertMsg({msg:"??????????????? ????????? ????????????."});
//					return false;
//				}
//			break;
//		}

		if($('#total_amount_h') === undefined){
		}else{
			if($('#ec_total_amount_h') === undefined){
			}else{
				if($('#total_amount_h').val()<0) {
					showAlertMsg({msg:"?????????????????? ?????? ?????? ??????????????? ?????????."});
					return;
				}
			}
		}
		
		/* -------------------------------------------------- */
		// 1?????? : ?????? ?????? ????????????
		/* -------------------------------------------------- */
		if (sessionStorage.getItem("ss_order_type") == "P") { // ?????????????????? ????????? ????????? ??????.
			var branch_data = JSON.parse(sessionStorage.getItem("ss_branch_data"));
		} else {
			var addr_data = JSON.parse(sessionStorage.getItem("ss_addr_data"));
			var branch_data = JSON.parse(sessionStorage.getItem("ss_branch_data"));
			
			if($("#cart_form input[name='h_code']").val() != undefined && $("#cart_form input[name='h_code']").val() != "" && (addr_data.h_code == "" || addr_data.h_code == undefined)){
				addr_data["h_code"] = $("#cart_form input[name='h_code']").val();
				sessionStorage.setItem("ss_addr_data", JSON.stringify(addr_data));
			}
		}
		// ?????????????????? ???????????? ???????????? ???
		if (branch_data != "" && typeof(branch_data) != "undefined" && branch_data != "" && branch_data != null) {
		} else {
			if(sessionStorage.getItem("M_1695_0_") || sessionStorage.getItem("M_1696_0_")){
				showAlertMsg({msg:"????????? ??????????????? ????????? ???????????????. ???????????? ??????????????????.", ok: function(){
					document.location.href='/order/delivery.asp?order_type=R';
				}});
			}else{
				showAlertMsg({msg:"??????????????? ?????????????????????. ?????????????????? ???????????? ????????????.", ok: function(){
					document.location.href='/order/selection.asp';
				}});
			}
			return;
		}


		/* -------------------------------------------------- */
		// 2?????? : ?????? ?????? ????????????
		/* -------------------------------------------------- */
		let tot_price = 0;
		var cartV = getAllCartEcMenu();
		var cartEcList = getCartEcPinList();
		if(cartV.length == 0) {
			showAlertMsg({msg:"??????????????? ????????? ????????????."});
			return;
		}

		for (i=0; i<cartV.length; i++) {
			tot_price += Number(cartV[i].value.price);
		}

		/* -------------------------------------------------- */
		// 3?????? : ?????? ?????? ??????????????????
		// 4?????? : ???????????? ????????? payment ?????? ?????? (e-coupon ????????? ?????? ??????????????? ?????????)
		/* -------------------------------------------------- */
		br_id = branch_data.branch_id;

		$.ajax({
			method: "post",
			url: "/api/ajax/ajax_getStoreOnline.asp",
			data: {"branch_id": br_id},
			dataType: "json",
			success: function(res) {
				if(res.result == "0000") {
					$.ajax({
						method: "post",
						url: "/api/ajax/ajax_eventshop_check.asp",
						data: {"MENUIDX":$("#CART_IN_PRODIDX").val(),"BRANCH_ID":br_id},
						dataType: "json",
						success: function(data) {
							if(data.result == "9999") {
								showAlertMsg({msg:data.message});
							}else{
								// ??????
								cpnPinSave();
								$("#cart_form input[name=cart_value]").val(JSON.stringify(cartV));
								$("#cart_form input[name=cart_ec_list]").val(cartEcList);
								$("#cart_form").submit();
							}
						},
						error: function(xhr) {
							showAlertMsg({msg:"????????? ????????? ??????????????????."});
						}
					});

				} else {
					showAlertMsg({msg:res.message});
				}
			},
			error: function(xhr) {
				showAlertMsg({msg:"?????? ????????? ?????? ??????????????????."});
			}
		});


//		if (tot_price < 15000) {
//			showAlertMsg({msg:"????????????????????? 15,000??? ?????? ??????????????? ?????????"});
//			return;
//		}


		// ?????? ?????????
		// ?????????????????? ?????? ??? ??? ????????????
		// ????????????????????? ?????? ??? ??? ????????? ??????
		// ????????????????????? ??? ??? ?????? ?????? ????????? ?????? ????????? ??????.
//		if (sessionStorage.getItem("ss_order_type") == "P") {
//			document.getElementById("spent_time").value = "30";
//		}


	}

	function after_control()
	{
		var after_arr = document.getElementsByName("after");

		for (i=0; i<after_arr.length; i++)
		{
			if (after_arr[i].checked)
			{
				document.getElementById("spent_time").value = after_arr[i].value;
			}
		}
	}

    $(document).ready(function() {
		$('#txtPIN').keydown(function(key){
			if(key.keyCode == 13){
				eCouponUse("CA");
			}
		});
    });
</script>




	<%
		If CheckLogin() And vAddrIdx <> "" Then
	%>

	<script type="text/javascript">
		$(function(){
			selectShipAddress(<%=vAddrIdx%>);
		});
	</script>

	<%
		End If
	%>

	<script type="text/javascript">
		function setScreen() {
			switch($("input[type=radio][name=orderType]:checked").val()) {
				case "D":
				$(".delivery-wrap").show();
				$(".pickup-wrap").hide();
				break;
				case "P":
				$(".delivery-wrap").hide();
				$(".pickup-wrap").show();
				break;
			}
		}

		function textSearch() {
			$.ajax({
				type: "post",
				url: "/api/ajax/shopListJs.asp",
				data:{"lat":$("#lat").val(),"lng":$("#lng").val(),"search_text":$.trim($("#search_text").val())},
				success: function(res){
					$("#search_store_list").html("");
					if(res.length > 0) {
					$.each(res, function(k,v){
						var shtml = "";

						shtml += "<div class=\"box\" id=\"br_"+v.branch_id+"\" value='"+JSON.stringify(v)+"'>\n";
						shtml += "\t<div class=\"name\">"+v.branch_name+"</div>\n";
						shtml += "\t<ul class=\"info\">\n";
						shtml += "\t\t<li>"+v.branch_tel+"</li>\n";
						shtml += "\t\t<li>"+v.branch_address+"</li>\n";
						shtml += "\t</ul>\n";
						shtml += "\t<ul class=\"btn-wrap\">\n";
						shtml += "\t\t<li>\n";
						shtml += "\t\t\t<button type=\"button\" onclick=\"selectStore('"+v.branch_id+"');\" class=\"btn btn-md btn-redLine w-100p btn-redChk\">??????</button>\n";
						shtml += "\t\t</li>\n";
						shtml += "\t</ul>\n";
						shtml += "</div>\n";

						$("#search_store_list").append(shtml);
					});
				}
				},
				error: function(xhr) {
					showAlertMsg({msg:xhr});
				}
			});
		}

		function selectStore(br_id) {
			$.ajax({
				method: "post",
				url: "/api/ajax/ajax_getStoreOnline.asp",
				data: {"branch_id": br_id},
				dataType: "json",
				success: function(res) {
					if(res.result == "0000") {
						$.ajax({
							method: "post",
							url: "/api/ajax/ajax_eventshop_check.asp",
							data: {"MENUIDX":$("#CART_IN_PRODIDX").val(),"BRANCH_ID":br_id},
							dataType: "json",
							success: function(data) {
								if(data.result == "9999") {
									showAlertMsg({msg:data.message});
								}else{
									var br_data = $("#br_"+br_id).attr("value");
									var branch_data = JSON.parse(br_data);

									$("#branch_id").val(br_id);
									$("#branch_data").val(br_data);
									$("#spent_time").val($(".pickup-wrap2 input[name=after]:checked").val());

									lpClose('.lp_shopSearch');
									setSelectedStore();
								}
							},
							error: function(xhr) {
								showAlertMsg({msg:"????????? ????????? ??????????????????."});
							}
						});

					} else {
						showAlertMsg({msg:res.message});
					}
				},
				error: function(xhr) {
					showAlertMsg({msg:"?????? ????????? ?????? ??????????????????."});
				}
			});
		}

		function setSelectedStore() {
			var branch_id = $("#branch_id").val();

			$("#selected_branch").html("<p class=\"explain\">?????? ?????? ????????? ?????? ??????????????? ?????????<br>????????? ?????????.</p>");

			if(branch_id != "") {
				var bd = JSON.parse($("#branch_data").val());

				$("#selected_branch").html("");

				var bhtml = "";
				bhtml += "<div class=\"box\">\n";
				bhtml += "\t<div class=\"name\">"+bd.branch_name+"</div>\n";
				bhtml += "\t<ul class=\"info\">\n";
				bhtml += "\t\t<li>"+bd.branch_tel+"</li>\n";
				bhtml += "\t\t<li>"+bd.branch_address+"</li>\n";
				bhtml += "\t</ul>\n";
				bhtml += "\t<ul class=\"btn-wrap\">\n";
				bhtml += "\t</ul>\n";
				bhtml += "</div>\n";
			
				$("#selected_branch").html(bhtml);

				lpClose('.lp_orderShipping');
				$("#order_type").val("P");

				$("#btn_order").show();
				setPickupAddress();
			}
		}

		function setPickupAddress() {
			setOrderTypeTitle();

			var bd = JSON.parse($("#branch_data").val());

			$("#branch_name").text(bd.branch_name);
			$("#branch_tel").text("("+bd.branch_tel+")");
			$("#ship_address").text(bd.branch_address);
		}

		function setOrderTypeTitle() {
			$("#btn_order").text("???????????? ??????");
			switch($("#order_type").val()) {
				case "D":
				$("#order_type_title").text("???????????? :");
				$("#address_title").text("???????????? :");
				$("#btn_order").text("??????????????????");
				break;
				case "P":
				$("#order_type_title").text("???????????? :");
				$("#address_title").text("???????????? :");
				$("#btn_order").text("??????????????????");
				break;
			}
			chkOrderInfo();
		}

		function chkOrderInfo() {
			switch($("#order_type").val()) {
				case "D":
				if($("#branch_id").val() != "" && $("#branch_data").val() != "" && $("#addr_id").val() != "" && $("#addr_data").val() != "") {
					//????????? ?????? ?????? (2022. 6. 7)
					var obj = $.parseJSON($("#addr_data").val()); 
					let h_code = obj.h_code;
					if(h_code == "" || h_code == undefined){
						//????????? ?????? ???????????? 
						selectCoordHCode("F", "", obj.address_road, $("#cart_form input[name=h_code]"));
					}
					$("#btn_order").show();
				} else {
					$("#order_type_title").text("???????????? ??? ???????????? ???????????? ???????????????.");
					$("#branch_name").text("");
					$("#address_title").text("");
					$("#ship_address").text("");
					$("#btn_order").hide();
				}
				break;
				case "P":
				if($("#branch_id").val() != "" && $("#branch_data").val() != "") {
					$("#btn_order").show();
				} else {
					$("#order_type_title").text("???????????? ??? ???????????? ???????????? ???????????????.");
					$("#branch_name").text("");
					$("#address_title").text("");
					$("#ship_address").text("");
					$("#btn_order").hide();
				}
				break;
				default:
				$("#order_type_title").text("???????????? ??? ???????????? ???????????? ???????????????.");
				$("#branch_name").text("");
				$("#address_title").text("");
				$("#ship_address").text("");
				$("#btn_order").text("???????????? ??????");
				$("#btn_order").hide();
				break;
			}
		}

		$(function(){
			$("#search_text").keypress(function(e){
				if(e.keyCode == 13) {
					e.preventDefault();
					textSearch();
				}
			});

			initLoc();

			setScreen();
			setOrderTypeTitle();
			
			var cV = getAllCartMenu();

			if(cV.length == 0) {
				$("#order_type_info").hide();
			}
		});

		function initLoc() {
			var uluru = {lat: 37.491872, lng: 127.115922};

			// Try HTML5 geolocation.
			if (navigator.geolocation) {
			  navigator.geolocation.getCurrentPosition(function(position) {
				var pos = {
				  lat: position.coords.latitude,
				  lng: position.coords.longitude
				};

				$('#lat').val(pos.lat);
				$('#lng').val(pos.lng);
				// loadTabList(pos);
				textSearch();
			  }, function() {
					$('#lat').val(uluru.lat);
					$('#lng').val(uluru.lng);
					textSearch();
			  });
			} else {
				$('#lat').val(uluru.lat);
				$('#lng').val(uluru.lng);
				textSearch();
			}
		}

		function openOrderType() {
			var order_type = $("#order_type").val();

			if(order_type == "") order_type = "D";
			$(".lp_orderShipping input[name=orderType][value="+order_type+"]").prop("checked", true);
			setScreen();
			lpOpen(".lp_orderShipping");
		}

		// 2019-05-23 ???????????? ?????? ??????
		$(function(){
			var len = getAllCartMenuCount();
			var cartprodidx = '';
			if(len == 0) {
			} else {
				for(var i = 0; i < len; i++) {
					var key = sessionStorage.key(i);

					if (sessionStorageException(key) == false) continue;

					var it = JSON.parse(sessionStorage.getItem(key));
					cartprodidx += ','+it.idx;
				}
			}
			$("#CART_IN_PRODIDX").val(cartprodidx);
		});
		// 2019-05-23 ???????????? ?????? ??????

		function goMenuList(){
			location.href='/menu/menuList.asp?order_type='+sessionStorage.getItem("ss_order_type");
		}

		$(document).ready(function(e){
			var cartList = getCouponFromCart();
			$("input[name=chkEcoupon]").each(function(){
				if( cartList.indexOf($(this).val()) != -1) {
					$(this).prop("checked", true);
				}else {
					$(this).prop("checked", false);
				}
			});

		});
	</script>



			<script type="text/javascript">
				function cart_all_clear_del()
				{
					clearCart(); 
					location.reload();
				}

				function cart_btn_con() {
					cart_all_del_cnt = getAllCartMenuCount();

					if (cart_all_del_cnt > 0) {
					} else {
						$('#cart_all_del').hide(0)
					}
				}

				cart_btn_con();
			</script>


	<!--#include virtual="/api/ta/cart.asp"-->

	<!-- Footer -->
	<!--#include virtual="/includes/footer.asp"-->
	<!--// Footer -->
