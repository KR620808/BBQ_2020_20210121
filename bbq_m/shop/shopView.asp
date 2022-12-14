<!--#include virtual="/api/include/utf8.asp"-->
<!doctype html>
<html lang="ko">
<head>
<!--#include virtual="/includes/top.asp"-->
</head>

<body>

<div class="wrapper">

	<%
		PageTitle = "매장찾기"
	%>
	<%
		Dim branch_id : branch_id = Request("branch_id")

		Dim cmd, rs

		Set cmd = Server.CreateObject("ADODB.Command")
		With cmd
			.ActiveConnection = dbconn
			.NamedParameters = True
			.CommandType = adCmdStoredProc
			.CommandText = "bp_branch_select"

			.Parameters.Append .CreateParameter("@branch_id", adVarChar, adParamInput, 20, branch_id)

			Set rs = .Execute
		End With
		Set cmd = Nothing

        If  (rs.BOF Or rs.EOF) Then
			response.write "존재하지 않는 매장입니다."
			response.end 
		end if 
		Dim branch_type, branch_type_arr, cnt, wgs84_x, wgs84_y, branch_weekday_open, branch_weekday_close, branch_services
		branch_type_arr = split(rs("branch_type"),";")
		cnt = UBound(branch_type_arr)
		branch_type = branch_type_arr(cnt)
		branch_type_arr = split(branch_type,":")
		cnt = UBound(branch_type_arr)
		branch_type = branch_type_arr(cnt)
		wgs84_x = rs("wgs84_x")
		wgs84_y = rs("wgs84_y")
		branch_weekday_open = rs("branch_weekday_open")
		branch_weekday_close = rs("branch_weekday_close")
		branch_services = rs("branch_services")
		beer_yn = rs("beer_yn")
	%>

	<!--#include virtual="/includes/header.asp"-->

	<!-- Container -->
	<div class="container">

		<!-- Aside -->
		<!--#include virtual="/includes/aside.asp"-->
		<!--// Aside -->
				
		<!-- Content -->
		<article class="content content-shopList">

			<!-- 매장 상세 -->
			<div class="shop_view">
				<div class="img inbox1000_2"><img src="/images/shop/test_shopdetail.jpg" alt=""></div>
				<div class="area inbox1000">
					<div class="icon">
						<span class="ico_shop"><%=branch_type%></span>
						<span class="ico_membership">멤버십</span>
<%		if beer_yn = "Y" or beer_yn = "N" then %>
						<span class="ico_membership" style="margin-right:5px;">수제맥주</span>
<%		end if %>
					</div>
					<div class="title">
						<p class="subject"><%=rs("branch_name")%></p>
						<p class="sum"><%=rs("branch_tel")%></p>
						<p class="address"><%=rs("branch_address")%></p>
						<a href="tel:<%=rs("branch_tel")%>" class="tel">전화하기</a>
					</div>
					<div class="info">
						<dl>
							<dt>영업시간</dt>
							<dd><%=branch_weekday_open%> ~ <%=branch_weekday_close%></dd>
						</dl>
						<dl>
							<dt>좌석수</dt>
							<dd><%=rs("branch_seats")%> 석</dd>
						</dl>
						<dl class="service_provided">
							<dt>제공서비스</dt>
							<dd><!--
								<ul>
									<li><p><img src="/images/shop/ico_parking.png" alt=""></p> 주차</li>
									<li><p><img src="/images/shop/ico_wifi.png" alt=""></p> 와이파이</li>
									<li><p><img src="/images/shop/ico_people.png" alt=""></p> 단체</li>
								</ul>
								-->
								<ul>
									<%If Left(branch_services,1) = "1" THEN%>
									<li><em><img src="/images/shop/ico_parking.png" alt=""></em> <span>주차</span></li>
									<%End IF%>
									<%If Mid(branch_services,3,1) = "1" THEN%>
									<li><em><img src="/images/shop/ico_wifi.png" alt=""></em> <span>와이파이</span></li>
									<%End IF%>
									<%If Mid(branch_services,4,1) = "1" THEN%>
									<li><em><img src="/images/shop/ico_people.png" alt=""></em> <span>단체</span></li>
									<%End IF%>
								</ul>
							</dd>
						</dl>
					</div>				
					<!-- <div id="map"></div> -->
				</div>
			</div>
			<!-- //매장 상세 -->

		</article>
		<!--// Content -->

	</div>
	<!--// Container -->

	<!-- Footer -->
	<!--#include virtual="/includes/footer.asp"-->
	<!--// Footer -->

<script>
function initMap() {

	var myLatLng = {lat: <%=wgs84_y%>, lng: <%=wgs84_x%>};
	var map = new google.maps.Map(document.getElementById('map'), {
		center: myLatLng,
		zoom: 15,
		gestureHandling: 'greedy'
	});

	var image = '/images/shop/ico_marker_bbq.png';
	var marker = new google.maps.Marker({
		map: map,
		position: myLatLng,
		icon: image
	});
}
</script>
<script async defer src="https://maps.googleapis.com/maps/api/js?key=<%=GOOGLE_MAP_API_KEY%>&callback=initMap&region=kr"></script>
