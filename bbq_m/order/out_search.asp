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

<script type="text/javascript">
	var order_type_str = "<%=order_type%>";
</script>

</head>

<body>

<div class="wrapper">

	<%
		PageTitle = "????????????"
	%>

	<!--#include virtual="/includes/header.asp"-->

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

		//	function textSearch() {
		//		$.ajax({
		//			type: "post",
		//			url: "/api/ajax/shopListJs.asp",
		//			data:{"lat":$("#lat").val(),"lng":$("#lng").val(),"search_text":$.trim($("#search_text").val())},
		//			success: function(res){
		//				$("#search_store_list").html("");
		//				if(res.length > 0) {
		//				$.each(res, function(k,v){
		//					var shtml = "";
		//
		//					shtml += "<div class=\"box\" id=\"br_"+v.branch_id+"\" value='"+JSON.stringify(v)+"'>\n";
		//					shtml += "\t<div class=\"name\">"+v.branch_name+"</div>\n";
		//					shtml += "\t<ul class=\"info\">\n";
		//					shtml += "\t\t<li>"+v.branch_tel+"</li>\n";
		//					shtml += "\t\t<li>"+v.branch_address+"</li>\n";
		//					shtml += "\t</ul>\n";
		//					shtml += "\t<ul class=\"btn-wrap\">\n";
		//					shtml += "\t\t<li>\n";
		//					shtml += "\t\t\t<button type=\"button\" onclick=\"selectStore('"+v.branch_id+"');\" class=\"btn btn-md btn-redLine w-100p btn-redChk\">??????</button>\n";
		//					shtml += "\t\t</li>\n";
		//					shtml += "\t</ul>\n";
		//					shtml += "</div>\n";
		//
		//					$("#search_store_list").append(shtml);
		//				});
		//			}
		//			},
		//			error: function(xhr) {
		//				showAlertMsg({msg:xhr});
		//			}
		//		});
		//	}

		function textSearch() {
			$.ajax({
				type: "post",
				url: "/api/ajax/shopListJs_new.asp",
				data:{"lat":$("#lat").val(),"lng":$("#lng").val(),"branch_id":"<%=branch_id%>"},
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
						shtml += "\t\t\t<button type=\"button\" onclick=\"selectStore('"+v.branch_id+"');\" class=\"btn_middle btn-redLine btn-redChk\">??????</button>\n";
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

									// ?????? ?????? ????????? ???????????? ?????? ??????.
									var cc = getAllCartMenuCount();

									if (cc>0 && sessionStorage.getItem("ss_branch_id") != br_id) 
									{
										alert("??????????????? ??????????????? ??????????????? ???????????????.");

										if(supportStorage()) {
											var len = sessionStorage.length
											var key_arr = new Array();
											var j=0;

											for(var i = 0; i < len; i++) {
												var key = sessionStorage.key(i);

												if (key != "" && typeof(key) != "undefined" && key != "" && key != null) {
													if (sessionStorageException(key) == false) continue;

													key_arr[j] = key;
													j++;
												} else {
												}
											}

											for(var i = 0; i < key_arr.length; i++) {
												if (key_arr[i] != "" && typeof(key_arr[i]) != "undefined" && key_arr[i] != "" && key_arr[i] != null) {
													sessionStorage.removeItem(key_arr[i]);
												}
											}
										}
									}

									sessionStorage.setItem("ss_branch_id", br_id);
									sessionStorage.setItem("ss_branch_data", br_data);

									//$("#spent_time").val($(".pickup-wrap2 input[name=after]:checked").val());

									// lpClose('.lp_shopSearch');
									//	setSelectedStore();
									//	document.cart_form.submit();
									location.href="/menu/menuList.asp";
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
				$("#btn_order").text("????????????");
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
		<!--#include virtual="/includes/aside.asp"-->
		<!--// Aside -->
			
		<!-- Content -->
		<article class="content">

			<!--#include virtual="/includes/step.asp"-->

			<!--include virtual="/includes/address.asp"-->

			<form id="cart_form" name="cart_form" method="post" action="delivery.asp">
				<input type="hidden" name="order_type" id="order_type" value="<%=order_type%>">
				<input type="hidden" name="branch_id" id="branch_id" value="<%=branch_id%>">
				<input type="hidden" name="branch_data" id="branch_data" value='<%=branch_data%>'>
				<input type="hidden" name="addr_idx" id="addr_idx" value="<%=addr_idx%>">
				<input type="hidden" name="cart_value">
				<input type="hidden" name="addr_data" id="addr_data" value='<%=addr_data%>'>
				<input type="hidden" name="spent_time" id="spent_time">
			</form>

			<!-- Layer Popup : ???????????? ?????? -->
			<div id="LP_orderShipping" class="lp_shopSearch">

				<div class="page_title">
					<img src="/images/order/icon_house.png">
					<span>?????? ??????</span>
				</div>

				<!-- LP Container -->
				<div class="lp-container">
					<!-- LP Content -->
					<div class="lp-content">
						<form action="">

							<!-- ?????? ?????? -->
							<div class="inner" style="display:none;">
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
								<section class="section section_shipList" id="search_store_list">
									<!-- ????????? ?????? ?????? : [search_store_list] ?????? ?????? -->
								</section>
							</div>
							<!--// ?????? ?????? -->
						</form>

					</div>
					<!--// LP Content -->
				</div>
				<!--// LP Container -->
			</div>
			<!--// Layer Popup -->


		</article>
		<!--// Content -->

	</div>
	<!--// Container -->

	<!-- Footer -->
	<!--#include virtual="/includes/footer.asp"-->
	<!--// Footer -->
