<!--#include virtual="/api/include/utf8.asp"-->
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
	End If

	ShowOrderType = False
	If (order_type = "D" AND addr_data = "") Or (order_type = "P" And branch_data = "") Then
		ShowOrderType = True
	End If
%>
<!doctype html>
<html lang="ko">
<head>
<!--#include virtual="/includes/top.asp"-->
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
				url: "/api/ajax/ajax_getShop.asp",
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
				showAlertMsg({msg:"?????????????????? ???????????? ???????????????."});
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
		switch($("#order_type").val()) {
			case "D":
				if($("#addr_idx").val() == "") {
					showAlertMsg({msg:"??????????????? ???????????????."});
					return false;
				}

				if($("#branch_id").val() == "") {
					showAlertMsg({msg:"??????????????? ????????? ????????????."});
					return false;
				}
			break;
			case "P":
				if($("#branch_id").val() == "") {
					showAlertMsg({msg:"??????????????? ????????? ????????????."});
					return false;
				}
			break;
		}

		var cartV = getAllCartMenu();
		if(cartV.length == 0) {
			showAlertMsg({msg:"??????????????? ????????? ????????????."});
			return;
		}

		$("#cart_form input[name=cart_value]").val(JSON.stringify(cartV));
		$("#cart_form").submit();
	}
</script>
</head>

<body>
<div class="wrapper">
<%
	PageTitle = "????????????"
%>
	<!--#include virtual="/includes/header.asp"-->
	<hr>
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
		$("#btn_order").text("????????????");
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
				$("#btn_order").show();
				$(".order_way").css("display","none");
			} else {
				$("#order_type_title").text("???????????? ??? ???????????? ???????????? ???????????????.");
				$("#branch_name").text("");
				$("#address_title").text("");
				$("#ship_address").text("");
				$("#btn_order").hide();
				$(".order_way").css("display","inline-block");
			}
			break;
			case "P":
			if($("#branch_id").val() != "" && $("#branch_data").val() != "") {
				$("#btn_order").show();
				$(".order_way").css("display","none");
			} else {
				$("#order_type_title").text("???????????? ??? ???????????? ???????????? ???????????????.");
				$("#branch_name").text("");
				$("#address_title").text("");
				$("#ship_address").text("");
				$("#btn_order").hide();
				$(".order_way").css("display","inline-block");
			}
			break;
			default:
			$("#order_type_title").text("???????????? ??? ???????????? ???????????? ???????????????.");
			$("#branch_name").text("");
			$("#address_title").text("");
			$("#ship_address").text("");
			$("#btn_order").text("????????????");
			$("#btn_order").hide();
			$(".order_way").css("display","inline-block");
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
            if(key == ta_id) continue;
            var it = JSON.parse(sessionStorage.getItem(key));
            cartprodidx += ','+it.idx;
		}
	}
    $("#CART_IN_PRODIDX").val(cartprodidx);
});
// 2019-05-23 ???????????? ?????? ??????
</script>
	<!-- Container -->
	<div class="container">
		<!-- Aside -->
		<!--#include virtual="/includes/asidex.asp"-->
		<!--// Aside -->
		<hr>
			
		<!-- Content -->
		<article class="content">
			<form id="cart_form" name="cart_form" method="post" action="paymentx.asp">
				<input type="hidden" name="order_type" id="order_type" value="<%=order_type%>">
				<input type="hidden" name="branch_id" id="branch_id" value="<%=branch_id%>">
				<input type="hidden" name="branch_data" id="branch_data" value='<%=branch_data%>'>
				<input type="hidden" name="addr_idx" id="addr_idx" value="<%=addr_idx%>">
				<input type="hidden" name="cart_value">
				<input type="hidden" name="addr_data" id="addr_data" value='<%=addr_data%>'>
				<input type="hidden" name="spent_time" id="spent_time">
			</form>
<input type="hidden" id="CART_IN_PRODIDX">
			<!-- ?????? ???????????? -->
			<section class="section section_cartSum" id="order_type_info">
				<dl>
					<dt id="order_type_title">???????????? :</dt>
					<dd><span class="red" id="branch_name"><%=vBranchName%></span> <em id="branch_tel"><%=vBranchTel%></em></dd>
				</dl>
				<dl class="address">
					<dt id="address_title">???????????? :</dt>
					<dd><span class="txt_overflow" id="ship_address"><%=vAddress%></span> <button type="button" onclick="openOrderType();" class="btn btn-sm btn-grayLine btn_lp_open">??????</button></dd>
				</dl>
			</section>
			<!-- //?????? ???????????? -->

			<!-- ???????????? ????????? -->
			<section class="section section_orderDetail pad-t0" id="cart_list">
				<!-- <div class="mar-t40">
					<button type="button" class="btn btn-md btn-redLine w-100p">+ ?????? ?????? ????????????</button>
				</div> -->

				<div class="order_calc">
					<div class="top div-table mar-t30">
						<dl class="tr">
							<dt class="td">??? ????????????
							</dt><dd class="td" id="item_amount">0???</dd>
						</dl>
						<!-- <dl class="tr">
							<dt class="td">?????????
							</dt><dd class="td" id="delivery_fee">0???</dd>
						</dl> -->
					</div>
					<div class="bot div-table">
						<dl class="tr">
							<dt class="td">??????</dt>
							<dd class="td" id="total_amount">0<span>???</span></dd>
						</dl>
					</div>
				</div>
				
				
					<div class="mar-t40">
						<button type="button" onclick="location.href='/menu/menuList.asp';" class="btn btn-md btn-redLine w-100p">+ ?????? ????????????</button>
					</div>
				
				<div class="mar-t40">
					<button type="button" onclick="openOrderType();" class="btn btn-lg btn-red w-100p order_way"> ???????????? ???????????? </button>
				</div>
				
				
				<%If CheckLogin() Then%> 
				<%	Else %>
				<div class="mar-t40">
					<button type="button"  onclick="openLogin('mobile');"  class="btn btn-lg btn-red w-100p"> ????????? ????????? </button>
				</div>
				<%End If%>
				
				
			
				
				<div class="mar-t40">
					<button type="submit"<%If order_type = "" Then%> style="display: none;"<%End If%> class="btn btn-lg btn-red w-100p" onClick="javascript:goOrder();" id="btn_order"><%If order_type = "D" Then%>??????<%ElseIf order_type = "P" Then%>??????<%End If%>????????????</button>
				</div>
			</section>
			<!-- //???????????? ????????? -->

			<!-- Layer Popup : ????????? ?????? -->
			<div id="LP_orderShipping" class="lp-wrapper lp_orderShipping">
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

							<!-- ?????? ?????? ?????? -->
							<div class="inner">
								<ul class="order-moveType">
									<li>
										<label class="ui-radio" onclick="setScreen();">
											<input type="radio" name="orderType" value="D"<%If order_type = "D" Then%> checked="checked"<%End If%>>
											<span></span> ????????????
										</label>
									</li>
									<li>	
										<label class="ui-radio" onclick="setScreen();">
											<input type="radio" name="orderType" value="P"<%If order_type = "P" Then%> checked="checked"<%End If%>>
											<span></span> ????????????
										</label>
									</li>
								</ul>
							</div>
							<!-- //?????? ?????? ?????? -->

							<div class="delivery-wrap"<%If order_type = "P" Then%> style="display: none;"<%End If%>>
								<section class="section section_shipList mar-t40">
<%
	Set aCmd = Server.CreateObject("ADODB.Command")
	With aCmd
		.ActiveConnection = dbconn
		.NamedParameters = True
		.CommandType = adCmdStoredProc
		.CommandText = "bp_member_addr_select"

		.Parameters.Append .CreateParameter("@member_idno", adVarChar, adParamInput, 50, Session("userIdNo"))

		Set aRs = .Execute
	End With
	Set aCmd = Nothing

	If Not (aRs.BOF Or aRs.EOF) Then
		aRs.MoveFirst
		Do Until aRs.EOF
%>
									<div class="box">
										<div class="name">
											<%If aRs("is_main") = "Y" Then%><span class="red">[???????????????]</span><%End If%> <%=aRs("addr_name")%>
										</div>
										<ul class="info">
											<li><%=aRs("mobile")%></li>
											<li>(<%=aRs("zip_code")%>) <%=aRs("address_main")&" "&aRs("address_detail")%></li>
										</ul>
										<ul class="btn-wrap">
											<li>
												<button type="button" onclick="selectShipAddress(<%=aRs("addr_idx")%>)" class="btn btn-md btn-redLine w-100p btn-redChk">??????</button>
											</li>
										</ul>
									</div>
<%
			aRs.MoveNext
		Loop
	End If
	Set aRs = Nothing
%>
								</section>
								<div class="btn-wrap inner mar-t40">
									<button type="button" class="btn btn-lg btn-black w-100p" onclick="javascript:lpOpen('.lp_addShipping');">????????? ??????</button>
								</div>

								<div class="txt-basic inner mar-t20">
									- ????????? ????????? ??????????????? &gt; ???????????????????????? ???????????? ??? ????????????. 
								</div>
							</div>

							<!-- ???????????? -->
							<div class="pickup-wrap pickup-wrap2 mar-t30 " style="display:none">
								<span class="txt">????????????????????????</span>
								<div class="orderType-radio orderType-radio2">
									<label class="ui-radio">
										<input type="radio" name="after" value="30" id="after30" checked="checked">
										<span></span> 30??? ???
									</label>
									<label class="ui-radio">
										<input type="radio" name="after" value="45" id="after40">
										<span></span> 45??? ???
									</label>
									<label class="ui-radio">
										<input type="radio" name="after" value="60" id="after50">
										<span></span> 60??? ???
									</label>
									<label class="ui-radio">
										<input type="radio" name="after" value="90" id="after90">
										<span></span> 90??? ???
									</label>
								</div>
								<div class="txt-basic inner mar-t20">
									?????? ??????????????? 15??? ?????????.
								</div>
							</div>
							<!--// ???????????? -->
							<!--// ?????? ?????? -->
							<div class="pickup-wrap"<%If order_type = "P" Then%> style="display:none"<%End If%>>
								<h4>?????? ??????</h4>
								<section class="section section_shipList" id="selected_branch">
									<p class="explain">?????? ?????? ????????? ?????? ??????????????? ?????????<br>????????? ?????????.</p>
								</section>
								<div class="btn-wrap inner mar-t40">
									<button type="button"  onclick="javascript:lpOpen('.lp_shopSearch');" class="btn btn-lg btn-black w-100p btn_lp_open">?????? ?????? ??????</button>
								</div>
							</div>
							<!--// ?????? ?????? -->							
						</form>
					</div>
					<!--// LP Content -->
				</div>
				<!--// LP Container -->
				<button type="button" class="btn btn_lp_close"><span>??????????????? ??????</span></button>
			</div>
			<!--// Layer Popup -->

			<!-- Layer Popup : ????????? ?????? - ????????????(????????????) -->
			<div id="LP_orderShipping" class="lp-wrapper lp_shopSearch">
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

							<!-- ?????? ?????? -->
							<div class="inner">
								<div class="sch-wrap">
									<input type="hidden" id="lat">
									<input type="hidden" id="lng">
									<input type="text" class="sch-word" id="search_text">
									<button type="button" class="btn-sch" onclick="textSearch();"><img src="/images/order/btn_search.png" alt="??????"></button>
								</div>
							</div>
							<!-- //?????? ?????? -->

							<!-- ?????? ????????? -->
							<div class="shop-listWrap">
								<section class="section section_shipList mar-t40" id="search_store_list">
									<div class="box">
										<div class="name">????????? 1???</div>
										<ul class="info">
											<li>010-1111-1111</li>
											<li>(01234) ??????????????? ????????? ????????? 66 ???????????? 1???</li>
										</ul>
										<ul class="btn-wrap">
											<li>
												<button type="button" class="btn btn-md btn-redLine w-100p btn-redChk">??????</button>
											</li>
										</ul>
									</div>
									<div class="box">
										<div class="name">????????????????????????(???????????????)</div>
										<ul class="info">
											<li>010-1111-1111</li>
											<li>(01234) ??????????????? ????????? ????????? 66 ???????????? 1???</li>
										</ul>
										<ul class="btn-wrap">
											<li>
												<button type="button" class="btn btn-md btn-redLine w-100p btn-redChk">??????</button>
											</li>
										</ul>
									</div>
								</section>
							</div>
							<!--// ?????? ?????? -->
						</form>
					</div>
					<!--// LP Content -->
				</div>
				<!--// LP Container -->
				<button type="button" class="btn btn_lp_close"><span>??????????????? ??????</span></button>
			</div>
			<!--// Layer Popup -->

			<!-- ?????? ?????? -->
			<div class="menu-cart">
				<div class="sideMenu">
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
						</div>
					</div>
<%
				End If
%>
					<div class="wrap">
						<h3><%=aRs("category_name")%></h3>
						<div class="area">
<%
				category_name = aRs("category_name")
			End If
%>
							<div class="box" id="S_<%=aRs("menu_idx")%>_0" onclick="javascript:toggleCartSide('<%=menuKey%>', 'S$$<%=aRs("menu_idx")%>$$0$$<%=aRs("menu_price")%>$$<%=aRs("menu_name")%>$$');">
								<div class="img">
									<label>
										<input type="checkbox">
										<img src="<%=SERVER_IMGPATH%><%=thumb_file_path%><%=thumb_file_name%>"/>
									</label>
								</div>
								<div class="info">
									<p class="name"><%=aRs("menu_name")%></p>
									<p class="pay"><%=FormatNumber(aRs("menu_price"),0)%>???</p>
								</div>
							</div>
<%
			aRs.MoveNext
		Loop
%>
						</div>
					</div>
<%
	End If

	Set aRs = Nothing
%>					
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
			<!-- //?????? ?????? -->

			<!-- ???????????? ?????? -->
			<div class="cart-fix on display-n" style="transition:0s;">
				<button type="button" class="btn btn-md btn-red btn_menu_cart" onclick="javascript:sideChangeApply();">???????????? ??????</button>
			</div>
			<!-- //???????????? ?????? -->



		</article>
		<!--// Content -->

		<!-- Back to Top -->
		<a href="#Top" class="btn btn_scrollTop">????????? ???????????? ??????</a>
		<!--// Back to Top -->
	</div>
	<!--// Container -->
	<hr>

	<!-- Footer -->
	<!--#include virtual="/includes/footer.asp"-->
	<!--// Footer -->
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
				<div class="inner">
					<dl class="regForm hide">
						<dt>??????</dt>
						<dd>
							<input type="text" name="addr_name" class="w-100p">
						</dd>
					</dl>
					<dl class="regForm hide">
						<dt>????????????</dt>
						<dd>
							<span class="ui-group-tel">
								<span><input type="text" name="mobile1" onlynum maxlength="3"></span>
								<span class="dash">-</span>
								<span><input type="text" name="mobile2" onlynum maxlength="4"></span>
								<span class="dash">-</span>
								<span><input type="text" name="mobile3" onlynum maxlength="4"></span>
							</span>
						</dd>
					</dl>
					<dl class="regForm">
						<dt><label for="zip_code">??????</label></dt>
						<dd>
							<div class="ui-input-post">
								<input type="text" name="zip_code" id="zip_code" maxlength="7" readonly onfocus="this.blur()" onClick="javascript:showPostcode();">
								<button type="button" onClick="javascript:showPostcode();" class="btn btn-md btn-gray btn_post"><span>???????????? ??????</span></button>
							</div>
							<div class="mar-t10"><input type="text" name="address_main" id="address_main" maxlength="100" readonly="" class="w-100p" onfocus="this.blur()" onClick="javascript:showPostcode();"></div>
							<div class="mar-t10"><input type="text" name="address_detail" maxlength="30" class="w-100p"></div>
						</dd>
					</dl>
				</div>
				<% If instr(Request.ServerVariables("HTTP_USER_AGENT"), "bbqAOS") > 0 Then %>
				<div id="wrap_daum"  class="daum_search" style="background:#fff;">
				<img class="search_close" src="//t1.daumcdn.net/postcode/resource/images/close.png" id="btnFoldWrap" onclick="foldDaumPostcode()" alt="?????? ??????">
				</div>
				<% End If %>
				<div class="btn-wrap two-up inner mar-t80">
					<button type="button" class="btn btn-lg btn-black" onclick="javascript:<% If CheckLogin() Then %>validAddress()<% Else %>validAddressNoMember()<% End If %>;"><span>??????</span></button>
					<button type="button" onClick="javascript:lpClose('.lp_addShipping');" class="btn btn-lg btn-grayLine"><span>??????</span></button>
				</div>
			</form>
		</div>
		<!--// LP Content -->
	</div>
	<!--// LP Container -->
	<button type="button" class="btn btn_lp_close"><span>??????????????? ??????</span></button>
</div>
<!--// Layer Popup -->
</body>
</html>