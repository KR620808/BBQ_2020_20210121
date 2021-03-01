var cartPage = "";
var defaultPopupOption = "width=460, height=500, toolbar=no, location=no, scrollbars=no, resizable=no, menubar=no";
var pgPopupOption = "width=704, height=504, toolbar=no, location=no, scrollbars=no, resizable=no, menubar=no";
var pgPhonePopupOption = "width=520, height=650, toolbar=no, location=no, scrollbars=no, resizable=no, menubar=no";


$(function(){
    // drawCartPage("P");
    $("input:text[numberOnly]").on("focus", function() {
        var x = $(this).val();
        x = removeCommas(x);
        $(this).val(x);
    }).on("focusout", function(){
        var x = $(this).val();
        if(x && x.length > 0) {
            if (!$.isNumeric(x)) {
                x = x.replace(/[^0-9]/g,"");
            }
            x = addCommas(x);
            $(this).val(x);
        }
    }).on("keyup", function(){
        $(this).val($(this).val().replace(/[^0-9]/g, ""));
    });


    $("input:text[onlynum]").on("focus", function() {
        var x = $(this).val();
        x = removeCommas(x);
        $(this).val(x);
    }).on("focusout", function(){
        var x = $(this).val();
        if(x && x.length > 0) {
            if (!$.isNumeric(x)) {
                x = x.replace(/[^0-9]/g,"");
            }
            // x = addCommas(x);
            $(this).val(x);
        }
    }).on("keyup", function(){
        $(this).val($(this).val().replace(/[^0-9]/g, ""));
    });
    chkCartMenuCount();

});

function dataToJson(form) {
    var unindexed_array = $(form).serializeArray();
    var indexed_array = {};

    $.map(unindexed_array, function(v, k){
        indexed_array[v['name']] = v['value'];
    });

    return indexed_array;
}

function showAlertMsg(opt) {
    if(domain == "pc") {
        if($("#lp_alert").length > 0) {
            lpOpen("#lp_alert");
            $("#lp_aiert .btn-red").unbind("click");
            $("#lp_alert .btn-red").on("click", function(){
                lpClose("#lp_alert");
            });
            $("#lp_alert .lp-msg").text(opt.msg);
            if(opt.ok != null) {
                $("#lp_alert .btn-red").on("click", opt.ok);
            }
        } else {
            alert(opt.msg);
            if(opt.ok != null) {
                opt.ok();
            }
        }
    } else if(domain == "mobile") {
        if($("#lp_alert").length > 0) {
            lpOpen2("#lp_alert");
            $("#lp_aiert .btn-red2").unbind("click");
            $("#lp_alert .btn-red2").on("click", function(){
                lpClose2("#lp_alert");
            });
            $("#lp_alert .lp-msg").text(opt.msg);
            if(opt.ok != null) {
                $("#lp_alert .btn-red2").on("click", opt.ok);
            }
        } else {
            alert(opt.msg);
            if(opt.ok != null) {
                opt.ok();
            }
        }
    }
}

function showConfirmMsg(opt) {
    if(domain == "pc") {
        if($("#lp_confirm").length > 0) {
            lpOpen("#lp_confirm");
            $("#lp_confirm .btn-red").unbind("click");
            $("#lp_confirm .btn-red").on("click", function(){
                lpClose("#lp_confirm");
            });
            $("#lp_confirm .btn-gray").on("click", function(){
                lpClose("#lp_confirm");
            });
            $("#lp_confirm .lp-msg").text(opt.msg);
            if(opt.ok != null) {
                $("#lp_confirm .btn-red").on("click", opt.ok);
            }
            if(opt.cancel != null) {
                $("#lp_confirm .btn-gray").on("click", opt.cancel);
            }
        } else {
            if(window.confirm(opt.msg)) {
                if(opt.ok != null) {
                    opt.ok();
                }
            } else {
                if(opt.cancel != null) {
                    opt.cancel();
                }
            }
        }
    } else if(domain == "mobile") {
        if($("#lp_confirm").length > 0) {
            lpOpen2("#lp_confirm");
            $("#lp_confirm .btn-red2").unbind("click");
            $("#lp_confirm .btn-red2").on("click", function(){
                lpClose2("#lp_confirm");
            });
            $("#lp_confirm .btn-gray2").on("click", function(){
                lpClose2("#lp_confirm");
            });
            $("#lp_confirm .lp-msg").text(opt.msg);
            if(opt.ok != null) {
                $("#lp_confirm .btn-red2").on("click", opt.ok);
            }
            if(opt.cancel != null) {
                $("#lp_confirm .btn-gray2").on("click", opt.cancel);
            }
        } else {
            if(window.confirm(opt.msg)) {
                if(opt.ok != null) {
                    opt.ok();
                }
            } else {
                if(opt.cancel != null) {
                    opt.cancel();
                }
            }
        }
    }
}

//--------------------------------------------------------
// 숫자
//--------------------------------------------------------
function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function addCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
function removeCommas(x) {
    if(!x || x.length == 0) return "";
    else return x.split(",").join("");
}


function chkCartMenuCount() {
    var cc = getAllCartMenuCount();

    $("#cart_item_count").text(cc);

    if(cc > 0) {
        $("#cart_item_count").show();
    } else {
        $("#cart_item_count").hide();
    }
}

//--------------------------------------------------------
// 장바구니....
//--------------------------------------------------------
function addCartMenu(data) {
    if(supportStorage()) {
		data += "$$";	//더미 추가
        var item = data.split("$$");

        var key = item[0]+"_"+item[1]+"_"+item[2];

        var jdata = getCartMenu(key);

        if(jdata == null) {
            jdata = {};
            jdata.type = item[0];
            jdata.idx = item[1];
            jdata.opt = item[2];
            jdata.price = item[3];
            jdata.nm = item[4];
            jdata.qty = 1;
            jdata.img = item[5];
            jdata.pin = item[6];
            jdata.side = {};
            saveCartMenu(key, JSON.stringify(jdata));
        }

        chkCartMenuCount();
        // var item = JSON.parse(data);
        getView();
    }
}

function addCartSide(key, data) {
    if(supportStorage()) {
        if(key == "" && sideChangeView != "") {
            key = sideChangeView;
        }
        var menu = getCartMenu(key);

        if(menu != null) {
            if(!menu.hasOwnProperty("side")) {
                menu.side = {};
            }

			data += "$$";	//더미 추가
            var item = data.split("$$");

            var skey = item[0]+"_"+item[1]+"_"+item[2];

            var jdata = getCartSide(key, skey);

            if(jdata == null) {
                jdata = {};
                jdata.type = item[0];
                jdata.idx = item[1];
                jdata.opt = item[2];
                jdata.price = item[3];
                jdata.nm = item[4];
                jdata.qty = 1;
                jdata.img = item[5];
	            jdata.pin = item[6];
            } else {
                jdata.qty = jdata.qty + 1;
            }
            menu.side[skey] = jdata;

            saveCartMenu(key, JSON.stringify(menu));

            getView();
        }
    }
}

function toggleCartSide(key, data) {
    if(supportStorage()) {
        if(key == "" && sideChangeView != "") {
            key = sideChangeView;
        }
        var menu = getCartMenu(key);

        var item = data.split("$$");

        var skey = item[0]+"_"+item[1]+"_"+item[2];

        if($("#"+skey).is(":checked")) {
            addCartSide(key, data);
        } else {
            removeCartSide(key, skey);
        }
    }
}
function getView() {
    if(sideChangeView != "") {
        setSideChange(sideChangeView);
    } else {
        switch(cartPage) {
            case "menu":
                drawCart();
                break;
            case "cart":
                drawCartPage("C");
                break;
            case "payment":
                drawCartPage("P");
                break;
            default:
                break;
        }
    }
    chkCartMenuCount();
}

function hasCartMenu(key) {
    if(supportStorage()) {
        var str = sessionStorage.getItem(key);

        if(str === null || str === undefined || str == "undefined") {
            return false;
        } else {
            return true;
        }
    }
    return false;
}

function getAllCartMenuCount() {
    if(supportStorage()) {
        var len = sessionStorage.length;

        var count = 0;

        for(var i=0; i < len; i++) {
            var key = sessionStorage.key(i);
            if(key == ta_id) continue;
			if(key.substring(0, 3) == "ss_") continue;
            count++;
        }

        return count;
    } else {
        return 0;
    }
}
function getAllCartMenu() {
    if(supportStorage()) {
        var len = sessionStorage.length;

        var cart = [];

        for(var i=0; i < len; i++) {
            var key = sessionStorage.key(i);
            if(key == ta_id) continue;
			if(key.substring(0, 3) == "ss_") continue;

            var value = JSON.parse(sessionStorage.getItem(key));

            var cart_value = {};
            cart_value.key = key;
            cart_value.value = value;
            cart.push(cart_value);
        }

        return cart;
    }
}

function clearCart() {
    if(supportStorage()) {
        var len = sessionStorage.length

        for(var i = 0; i < len; i++) {
            var key = sessionStorage.key(i);
			if(key == null) continue;
            if(key == ta_id) continue;
			if(key.substring(0, 3) == "ss_") continue;

            sessionStorage.removeItem(key);
        }
    }
}

function getCartMenu(key) {
    if(key == ta_id) return null;

    if(hasCartMenu(key)) {
        return JSON.parse(sessionStorage.getItem(key));
    }

    return null;
}

function getCartSide(key, skey) {
    if(hasCartMenu(key)) {
        var menu = getCartMenu(key);

        if(menu.hasOwnProperty("side")) {
            if(menu.side.hasOwnProperty(skey)) {
                return menu.side[skey];
            }
        }
    }

    return null;
}

function saveCartMenu(key, data) {
    if(supportStorage()) {
        sessionStorage.setItem(key, data);
    }
}

function saveCartSide(key, skey, data) {
    if(supportStorage()) {
        var menu = getCartMenu(key);

        if(menu != null) {
            var side = getCartSide(key, skey);

            if(side == null) {
                if(!menu.hasOwnProperty("side")) {
                    menu.side = {};
                }
                menu.side[skey] = data;
            }

            saveCartMenu(key, JSON.stringify(menu));
        }
    }
}

function removeCartMenu(key) {
    if(hasCartMenu(key)) {
        sessionStorage.removeItem(key);

        getView();
    }
}

function removeCartSide(key, skey) {
    if(supportStorage()) {
        var menu = getCartMenu(key);

        if(menu != null) {
            if(menu.hasOwnProperty("side")) {
                if(menu.side.hasOwnProperty(skey)) {
                    delete menu.side[skey];

                    saveCartMenu(key, JSON.stringify(menu));

                    getView();
                }
            }
        }
    }
}


function removeCartSideAll(key) 
{
    if(supportStorage()) 
	{
        var menu = getCartMenu(key);

        if(menu != null) {
            if(menu.hasOwnProperty("side")) {
                for(var skey in menu.side) {
					if(menu.side.hasOwnProperty(skey)) {
						delete menu.side[skey];

						saveCartMenu(key, JSON.stringify(menu));
					}
                }
            }
        }
    }
}

function removeCartSideNew(key, skey) {
    $("#"+skey+" :checkbox").prop("checked", false);
    removeCartSide(key, skey);
}

function changeMenuQty(key, qty) {
    if(supportStorage()) {
        var menu = getCartMenu(key);

        if(menu != null) {
            var mqty = menu.qty;

            if(mqty + qty > 0) {
                mqty += qty;
                menu.qty = mqty;

                saveCartMenu(key, JSON.stringify(menu));

                getView();
            }
        }
    }
}
//숫자로 직접입력하는 경우
function changeTxtMenuQty(key, qty) {
    if(supportStorage()) {
        var menu = getCartMenu(key);

        if(menu != null) {
			var mqty = eval(qty);
            if(mqty > 0) {
                menu.qty = mqty;

                saveCartMenu(key, JSON.stringify(menu));

                getView();
            }
        }
    }
}

function changeSideQty(key, skey, qty) {
    if(supportStorage()) {
        var menu = getCartMenu(key);

        if(menu != null) {
            var side = getCartSide(key, skey);

            if(side != null) {
                var sqty = side.qty;

                if(sqty + qty > 0) {
                    sqty += qty;
                    side.qty = sqty;

                    menu.side[skey] = side;

                    saveCartMenu(key, JSON.stringify(menu));

                    getView();
                }
            }
        }
    }
}

//숫자로 직접입력하는 경우
function changeTxtSideQty(key, skey, qty) {
    if(supportStorage()) {
        var menu = getCartMenu(key);

        if(menu != null) {
            var side = getCartSide(key, skey);

            if(side != null) {
                var sqty = eval(qty);

                if(sqty > 0) {
                    side.qty = sqty;

                    menu.side[skey] = side;

                    saveCartMenu(key, JSON.stringify(menu));

                    getView();
                }
            }
        }
    }
}

function supportStorage() {
    return typeof(Storage) !== "undefined";
}

//----------------------------------------------------------------------
//  장바구니 사이드변경 추가
//----------------------------------------------------------------------
var sideChangeView = "";
var sideChangeItem = null;


var ta_id = "tempAddress";

function getTempAddress() {
    if(supportStorage()) {
        if(hasCartMenu(ta_id)) {
            return JSON.parse(sessionStorage.getItem(ta_id));
        }
    }

    return null;
}

function saveTempAddress(address) {
    if(supportStorage()) {
        sessionStorage.setItem(ta_id, JSON.stringify(address));
    }
}

function getCurrentPage() {
    return window.location.pathname.split("/").pop();
}

function checkDeliveryShop(addrdata) {
    $.ajax({
        method: "post",
        url: "/api/ajax/ajax_getshop.asp",
        data: {data: JSON.stringify(addrdata)},
        dataType: "json",
        success: function(res) {
            if(res.result == "0000") {
                if(res.online_status != "Y") {
                    showAlertMsg({msg:"선택하신 지역에 배달 가능한 매장이 일시적으로 영업을 하지 않습니다."});
                } else {
					$.ajax({
						method: "post",
						url: "/api/ajax/ajax_eventshop_check.asp",
						data: {"MENUIDX":$("#CART_IN_PRODIDX").val(),"BRANCH_ID":res.branch_id},
						dataType: "json",
						success: function(data) {
							if(data.result == "9999") {
								showAlertMsg({msg:data.message});
							}else{
								setDeliveryShopInfo(res);
							}
						},
						error: function(xhr) {
							showAlertMsg({msg:"시스템 에러가 발생했습니다."});
						}
					});
                }
            } else if(res.result == "9000") {
                if(res.online_status != "Y") {
                    showAlertMsg({msg:res.message});
                } else {
                    setDeliveryShopInfo(res);
                }
            } else {
                showAlertMsg({msg:"배달가능한 매장이 없습니다."});
            }
            // if(res != "") {
            //     var rv = res.split(",");

            //     if(rv[1] == "Y") {
            //         getDeliveryShopInfo(rv[2]);
            //     } else {
            //         alert("해당 매장은 일시적으로 사용할 수 없습니다.");
            //     }
            // } else {
            //     alert("배달가능한 매장이 없습니다.");
            // }
        },
        error: function(xhr) {
            showAlertMsg({msg:"배달가능한 매장이 없습니다."});
        }
    });
}

function checkDeliveryShop_new(addrdata) {
    $.ajax({
        method: "post",
        url: "/api/ajax/ajax_getshop.asp",
        data: {data: JSON.stringify(addrdata)},
        dataType: "json",
        success: function(res) {

			$("#branch_data").val(JSON.stringify(res));
			$("#branch_id").val(res.branch_id);
			$("#branch_name").text(res.branch_name);

			$("#order_type").val("D");

			if (typeof(next_page_gubun) != "undefined" && next_page_gubun != "" && next_page_gubun != null) {
				if (next_page_gubun == "D") {
					go_next_page_map(next_page_gubun);
				}
			} else {
			}
        },
        error: function(xhr) {
            showAlertMsg({msg:"배달가능한 매장이 없습니다."});
        }
    });
}

// function getDeliveryShopInfo(branch_id) {
//     $.ajax({
//         method: "post",
//         url: "/api/ajax/ajax_getStoreInfo.asp",
//         data: {branch_id: branch_id},
//         success: function(res) {
//             var si = JSON.parse(res);
//             setDeliveryShopInfo(si);
//             // $("#branch_data").val(res);
//             // $("#branch_id").val(branch_id);
//             // $("#branch_name").text(si.branch_name);
//             // $("#branch_tel").text("("+si.branch_tel+")");

//             // lpClose(".lp_orderShipping");
//         }
//     });
// }

function selectShipAddress_new(addr_idx) {
    if(addr_idx == 0) {
        drawShipAddress_new(getTempAddress());
    } else {
        $.ajax({
            method: "post",
            url: "/api/ajax/ajax_getAddress.asp",
            data: {"addr_idx": addr_idx},
            dataType: "json",
            success: function(data) {
                drawShipAddress_new(data[0]);
            }
        });
    }
}

function selectShipAddress(addr_idx) {
    if(addr_idx == 0) {
        drawShipAddress(getTempAddress());
    } else {
        $.ajax({
            method: "post",
            url: "/api/ajax/ajax_getAddress.asp",
            data: {"addr_idx": addr_idx},
            dataType: "json",
            success: function(data) {
                drawShipAddress(data[0]);
            }
        });
    }
}

// function loginPop(domain, returnUrl){
//     window.open("/api/login.asp?domain="+domain+"&rtnUrl="+returnUrl,"","");
// }

function openJoin(domain) {
    domain = (typeof domain !== "undefined")? domain: "";
    window.open("/api/join.asp?domain="+domain,"","width=460, height=660, toolbar=no, location=no, scrollbars=yes, resizable=no, menubar=no");
}
function openLogin(domain) {
    domain = (typeof domain !== "undefined")? domain: "";
    returnUrl = (typeof returnUrl !== "undefined")? returnUrl: "";
    window.open("/api/login.asp?domain="+domain+"&rtnUrl="+returnUrl,"","width=460, height=610, toolbar=no, location=no, scrollbars=no, resizable=no, menubar=no");
}
function openPopup(url, name, option) {
    window.open(url,name,option);
}


function changeUserInfo(data) {
    $.ajax({
        method: "post",
        url: "/api/changeUserInfo.asp",
        data: data,
        dataType: "json",
        success: function(res) {
            showAlertMsg({msg:res.message, ok: function(){
                location.reload(true);
            }});
        }
    });
}

function changeUserInfo2(info) {
    $.ajax({
        method: "post",
        url: "/api/issueTicket.asp",
        data: {info: info},
        dataType: "json",
        success: function(res) {
            if(res.hasOwnProperty("header")) {
                if(res.header.hasOwnProperty("resultCode")) {
                    if(res.header.resultCode == 0) {
                        var url = "";

                        switch(info) {
                            case "pwd":
                            url = "/change-password"
                            break;
                            case "mobile":
                            url = "/change-cellphone-number";
                            break;
                        }

                        if(url != "") {
                            window.open(paycoAuthUrl+url+"?ticket="+res.data.ticket+"&appYn=N&logoYn=N&titleYn=N","", defaultPopupOption);
                        }
                    }
                }
            }
        }
    });
}

function onlyNum(objtext1){ 
	var inText = objtext1.value; 
	var ret; 
	for (var i = 0; i <= inText.length; i++) { 
		ret = inText.charCodeAt(i);
		if ((ret <= 47 && ret > 31) || ret >= 58)  { 
			alert("숫자만을 입력하세요"); 
			objtext1.value = ""; 
			objtext1.focus();
			return false; 
		}
	}
	return true; 
}

function go_site(SITE) {
    $.ajax({
        method: "post",
        url: "/api/site_move.asp",
        data: {"SITE":SITE},
        dataType: "json",
        success: function(res) {
			var f = document.SITE_MOVE;
			if (res.result == "1"){
				f.target = "_self";
			}else if (res.result == "2"){
				f.target = "_self";
			}else if (res.result == "3"){
				f.target = "_blank";
			}else{
	            showAlertMsg({msg:'준비중입니다.'});
				return;
			}
			f.action = res.url;
			f.submit();
        }
    });
}

function OpenUploadFILE(FILEID, UPID){
	UPDIR = $('#'+UPID).val();
	win = window.open('/api/Fileupload.asp?FILEID='+FILEID+'&UPDIR='+UPDIR,'OpenUploadFILE','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,status=no, left=50,top=50, width=600,height=200');
	win.focus();
}

function add_side_div(sidx)
{
    if(supportStorage()) 
	{
		var str = "";
		$('#payment_info_side_div').html('');

		$('.side_class').each(function(){
			if($(this).is(":checked")) {
				str += '<input type="hidden" id="S_'+ sidx +'_hide" name="S_'+ sidx +'_hide" class="side_hide_class" sidx="'+ sidx +'" value="'+ $(this).val() +'">';
			}
		});

		$('#payment_info_side_div').html(str);
	}

	view_price();
}

function view_price()
{
	tot_price = 0;

	vMenuPrice_price = Number($('#vMenuPrice').val() * $('#new_qty_'+ current_menu_key).val());
	side_price = 0;

	$('.side_hide_class').each(function(){
		item = $(this).val().split("$$");

		side_price += Number(item[3] * $('#new_qty_'+ current_menu_key).val());
	});

	tot_price = vMenuPrice_price + side_price;

	$('#pay_amount_new').html(addCommas(tot_price) +"원");
}

function control_menu_qty(num)
{
	var OnlyNumber = /^[0-9]+$/
	var qty = Number($('#new_qty_'+ current_menu_key).val());

	// 숫자가 아니면
	if (OnlyNumber.test(qty) == false) {
		$('#new_qty_'+ current_menu_key).val(0);
	} else {
		// 수량이 1이고 / -라면 
		if (qty <= 1 && num == -1) {
			$('#new_qty_'+ current_menu_key).val(1);
		} else {
			$('#new_qty_'+ current_menu_key).val(qty+num);
		}
	}

	view_price();
}

function goAddCart()
{
	removeCartMenu(current_menu_key);
	removeCartSideAll(current_menu_key);
	var qty = Number($('#new_qty_'+ current_menu_key).val());

	addCartMenu($('#menuItem').val());
	changeTxtMenuQty(current_menu_key, qty);

	$('.side_hide_class').each(function(){
		addCartSide(current_menu_key, $(this).val());

		item = $(this).val().split("$$");
		skey = item[0]+"_"+item[1]+"_"+item[2];

		changeTxtSideQty(current_menu_key, skey, qty);
	});
}

function goCart()
{
	goAddCart()

	$('#lp_alert .btn-wrap').hide(0);
	$('#lp_alert .btn_lp_close').hide(0);
	$('#lp_alert .lp-confirm-cont').css('padding','20px 20px 0');

	showAlertMsg({msg:"장바구니에 담았습니다"});

	setTimeout("history.back()", 800);

//	history.back();
}

function goOrder()
{
	goAddCart()

//	showAlertMsg({msg:"장바구니로 이동합니다."});
//
//	setTimeout("location.href='/order/cart.asp'", 800);

	location.href = "/order/cart.asp";
}

function goCartTxt(key, num)
{
	var qty = Number($('#new_qty_'+ key).val());

	if (qty <= 1 && num == -1) {
		return;
	}

	$('#new_qty_'+ key).val(qty + num);

	var qty = Number($('#new_qty_'+ key).val());

	changeTxtMenuQty(key, qty);

	$('#cart_list_'+ key +' .side_hide_class').each(function(){
		skey = $(this).val();

		changeTxtSideQty(key, skey, qty);
	});
}

function change_store_cart(br_id)
{
	// 다른 매장 선택시 장바구니 상품 제거.
	var cc = getAllCartMenuCount();

	// e-쿠폰때문에 넣음.
	// e-쿠폰 > 매장선택 해달라 msg > 매장선택시 다른 매장 선택했다!
	if (sessionStorage.getItem("ss_branch_id") != "" && typeof(sessionStorage.getItem("ss_branch_id")) != "undefined" && sessionStorage.getItem("ss_branch_id") != "" && sessionStorage.getItem("ss_branch_id") != null) {
		if (cc>0 && sessionStorage.getItem("ss_branch_id") != br_id) 
		{
			alert("다른매장을 선택하셔서 장바구니가 비워집니다.");

			if(supportStorage()) {
				var len = sessionStorage.length
				var key_arr = new Array();
				var j=0;

				for(var i = 0; i < len; i++) {
					var key = sessionStorage.key(i);

					if (key != "" && typeof(key) != "undefined" && key != "" && key != null) {
						if(key == null) continue;
						if(key == ta_id) continue;
						if(key.substring(0, 3) == "ss_") continue;

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
	}
}

//function tooggleCartMenu(menuDate, key, data) 
//{
//    if(supportStorage()) 
//	{
//		var cart_chk = "";
//
//		// side menu for
//		$('.side_class').each(function(){
//			if($(this).is(":checked")) {
//				cart_chk = "Y";
//			}
//		});
//
//		// checked yes
//		if (cart_chk == "Y") {
//			addCartMenu(menuDate);
//			toggleCartSide(key, data);
//		} else { /// checked no
//			var item = data.split("$$");
//
//			var skey = item[0]+"_"+item[1]+"_"+item[2];
//
//			removeCartMenu(key);
//            removeCartSide(key, skey);
//		}
//    }
//}

//function control_menuview(menuDate, str)
//{
//	var OnlyNumber = /^[0-9]+$/
//	var qty = Number($('#qty_'+ current_menu_key).val());
//
//	// 숫자가 아니면
//	if (OnlyNumber.test(qty) == false) {
//		$('#qty_'+ current_menu_key).val(0);
//	} else {
//		// 수량이 0이고 / -가 아니라면
//		if (qty == 0 && str != -1) {
//			addCartMenu(menuDate);
//		} else {
//			// 수량이 1이고 / -라면 
//			if (str == -1 && qty == 1) {
//				removeCartMenu(current_menu_key);
//				$('#qty_'+ current_menu_key).val(0);
//
//				// 사이드메뉴 초기화
//				$('.side_class').each(function(){
//					$(this).prop("checked", false);
//				});
//			} else {
//				changeMenuQty(current_menu_key, str);
//
//				// 사이드메뉴도 같이 제어
//				$('.hide_side').each(function(){
//					changeSideQty(current_menu_key, $(this).val(), str);
//				})
//			}
//		}
//	}
//}