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


function showMsg(opt) {
    if(domain == "pc") {
        if($("#lp_msg").length > 0) {
            lpOpen("#lp_msg");
            $("#lp_aiert .btn-red").unbind("click");
            $("#lp_msg .btn-red").on("click", function(){
                lpClose("#lp_msg");
            });
//            $("#lp_msg .lp-msg").text(opt.msg);
            $("#lp_msg .lp-msg").html(opt.msg);
            if(opt.ok != null) {
                $("#lp_msg .btn-red").on("click", opt.ok);
            }
        } else {
            alert(opt.msg);
            if(opt.ok != null) {
                opt.ok();
            }
        }
    } else if(domain == "mobile") {
        if($("#lp_msg").length > 0) {
            lpOpen2("#lp_msg");
            $("#lp_aiert .btn-red2").unbind("click");
            $("#lp_msg .btn-red2").on("click", function(){
                lpClose2("#lp_msg");
            });
//            $("#lp_msg .lp-msg").text(opt.msg);
            $("#lp_msg .lp-msg").html(opt.msg);
            if(opt.ok != null) {
                $("#lp_msg .btn-red2").on("click", opt.ok);
            }
        } else {
            alert(opt.msg);
            if(opt.ok != null) {
                opt.ok();
            }
        }
    }
}

function showAlertMsg(opt) {
    if(domain == "pc") {
        if($("#lp_alert").length > 0) {
            lpOpen("#lp_alert");
            $("#lp_aiert .btn-red").unbind("click");
            $("#lp_alert .btn-red").on("click", function(){
                lpClose("#lp_alert");
            });
//            $("#lp_alert .lp-msg").text(opt.msg);
            $("#lp_alert .lp-msg").html(opt.msg);
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
//            $("#lp_alert .lp-msg").text(opt.msg);
            $("#lp_alert .lp-msg").html(opt.msg);
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
//            $("#lp_confirm .lp-msg").text(opt.msg);
            $("#lp_confirm .lp-msg").html(opt.msg);
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
//            $("#lp_confirm .lp-msg").text(opt.msg);
            $("#lp_confirm .lp-msg").html(opt.msg);
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
// ??????
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
// ????????????....
//--------------------------------------------------------
function addCartMenu(data) {
    if(supportStorage()) {
		data += "$$";	//?????? ??????
        var item = data.split("$$");

        var key = item[0]+"_"+item[1]+"_"+item[2]+"_"+item[6];
        var jdata = getCartMenu(key);

        var pin = item[6];
        var addYn = "N"
        
        $.ajax({
            method: "post",
            url: "/api/ajax/ajax_getEcouponDup.asp",
            data: {"PIN": pin},
            dataType: "json",
            cache: false,
            async: false,
            headers: {"cache-control":"no-cache","pragma":"no-cache"},
            success: function(res) {
                // alert(res.dupYn+"/"+res.cpnId);
                if (res.dupYn == "N") {
                    var dup = hasDupMenu(res.cpnId);
                    if (dup == 1) {
                        alert("?????? ????????? ???????????? 1?????? ??? 1?????? ?????? ???????????????.\n?????? ????????? ???????????? ??????????????? ????????? ????????????.");
                    } else {
                        addYn = "Y"
                    }
                } else {
                    addYn = "Y"
                }

                if (addYn == "Y") {
                    // alert('add');
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
                        jdata.cpnid = res.cpnId;
                        jdata.kindSel = item[7];
                        jdata.side = {};
                        saveCartMenu(key, JSON.stringify(jdata));
                    }
                    chkCartMenuCount();
                    // var item = JSON.parse(data);
                    getView();
                }
            },
            error: function(data, status, err) {
                alert(data + ' ' + status + '\n????????? ????????? ?????? ?????? ?????? ?????? ?????? ??? ????????? ??????????????????.');
            }
        });	
    }
}

function hasDupMenu(cpnId) {
    if(supportStorage()) {
        // alert('dup function');
        var len = sessionStorage.length;

        for(var i=0; i < len; i++) {
            var key = sessionStorage.key(i);
            try {
                var sessionCpnid = JSON.parse(sessionStorage.getItem(key)).cpnid;

                if (sessionCpnid == cpnId) {
                    // alert('has');
                    return 1;
                }
            } catch(err) {}
        }
        return 0;
    } else {
        return 0;
    }
}

function cpnPinSave() {
    if(supportStorage()) {
        var len = sessionStorage.length;
        var pinsave = "";
        for(var i=0; i < len; i++) {
            var key = sessionStorage.key(i);
            try {
                var sessionPin = JSON.parse(sessionStorage.getItem(key)).pin;
                pinsave = pinsave + ',' + sessionPin;
            } catch(err) {}
        }
        
        sessionStorage.setItem("ss_pin_save", pinsave);
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

			data += "$$";	//?????? ??????
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
                jdata.cpnid = "";
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

			if (sessionStorageException(key) == false) continue;

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

			if (sessionStorageException(key) == false) continue;

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
		var key_arr = Array();
        var len = sessionStorage.length

        for(var i = 0; i < len; i++) {
            var key = sessionStorage.key(i);

			if(key.substring(0, 3) == "ec_") { // e?????? ????????? ????????? 
				key_arr.push(key);
			}
			if (sessionStorageException(key) == false) continue;

			key_arr.push(key);
        }

		// ????????? ?????? ???????????? 5???????????????
		// ???????????? ????????? ?????? ?????????;
        for(var i = 0; i < key_arr.length; i++) {
            sessionStorage.removeItem(key_arr[i]);

            if(key_arr[i] == "M_1695_0_" || key_arr[i] == "M_1696_0_"){
                sessionStorage.removeItem("ss_order_type");
                sessionStorage.removeItem("ss_branch_id");
                sessionStorage.removeItem("ss_branch_data");
                sessionStorage.removeItem("ss_addr_idx");
                sessionStorage.removeItem("ss_addr_data");
                sessionStorage.removeItem("ss_spent_time");
            }
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
        if(key == "M_1695_0_" || key == "M_1696_0_"){
            if(sessionStorage.getItem("M_1695_0_") || sessionStorage.getItem("M_1696_0_")){
            }else{
                sessionStorage.removeItem("ss_order_type");
                sessionStorage.removeItem("ss_branch_id");
                sessionStorage.removeItem("ss_branch_data");
                sessionStorage.removeItem("ss_addr_idx");
                sessionStorage.removeItem("ss_addr_data");
                sessionStorage.removeItem("ss_spent_time");

                location.reload(true);
            }
        }
        getView();
    }
}

function getCartPartyCount(){
    if(supportStorage()) {
        var len = sessionStorage.length;

        var count = 0;

        for(var i=0; i < len; i++) {
            var key = sessionStorage.key(i);

			if (key.substring(0, 9) == "M_1695_0_" || key.substring(0, 9) == "M_1696_0_"){
				count++;
			}
        }

        return count;
    } else {
        return 0;
    }
}

function getCartEcAmtCount() {
    if(supportStorage()) {
        var len = sessionStorage.length;

        var count = 0;

        for(var i=0; i < len; i++) {
            var key = sessionStorage.key(i);

			if (key.substring(0, 3) == "ec_"){
				count++;
			}
        }

        return count;
    } else {
        return 0;
    }
}

function resetCartMenuEcAmt() {
	//e?????? ???????????? ????????? 
    if(supportStorage()) {
		var key_arr = Array();
        var len = sessionStorage.length
		
		for(var i = 0; i < len; i++) {
			var key = sessionStorage.key(i);
			
			if(key == null) continue;
			if(key.substring(0, 3) == "ec_" || key.substring(0, 2) == "M_" ) {
				var str = sessionStorage.getItem(key);
				
				if(str === null || str == "" || str === undefined || str == "undefined") continue;
				
				var it = JSON.parse(str);
				if (it.pin != ''){
					key_arr.push(key);
				}
			}
		}
		
		// ????????? ?????? ???????????? ???????????? ????????? ?????????;
        for(var i = 0; i < key_arr.length; i++) {
			sessionStorage.removeItem(key_arr[i]);
			console.log("resetCartMenuEcAmt remove : " + key_arr[i]);
        }
	}
}

function getCartEcAmt() {
	var len = sessionStorage.length;
	var goods_len = getCartEcAmtCount();
	var result = 0;
	if(goods_len > 0) {
		for(var i = 0; i < len; i++) {
			var side_amt_new = 0;
			var key = sessionStorage.key(i);

			if(key.substring(0, 3) == "ec_") {
				var str = sessionStorage.getItem(key);
				
				if(str === null || str == "" || str === undefined || str == "undefined") continue;
				
				var it = JSON.parse(str);
				
				if (it.pin != ''){
					result += Number(it.price);
				}
			}
		}
	}
	return result;
}

function getCartEcPinList() {
    if(supportStorage()) {
        var len = sessionStorage.length;

        var cart = "";

        for(var i=0; i < len; i++) {
            var key = sessionStorage.key(i);

			if(key.substring(0, 3) == "ec_") { // e?????? ????????? ????????????
				var value = JSON.parse(sessionStorage.getItem(key));
				if (cart != "") cart += "||";
					
				cart += value.pin;
			}
        }
        return cart;
    }
}

function getAllCartEcMenu() {
    if(supportStorage()) {
        var len = sessionStorage.length;

        var cart = [];

        for(var i=0; i < len; i++) {
            var key = sessionStorage.key(i);

			if(key.substring(0, 3) == "ec_") { // e?????? ????????? ????????????
			} else {
				if (sessionStorageException(key) == false) continue;
			}
            var value = JSON.parse(sessionStorage.getItem(key));

            var cart_value = {};
            cart_value.key = key;
            cart_value.value = value;
            cart.push(cart_value);
        }

        return cart;
    }
}
function couponToAmt(key) {
    if(supportStorage()) {
		var menu = getCartMenu(key);

        if(menu != null) {
			saveCartMenu("ec_"+key, JSON.stringify(menu));
		}
	}
	removeCartMenu(key);
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
//????????? ?????????????????? ??????
function changeTxtMenuQty(key, qty) {
    if(supportStorage()) {
        if (key.substring(key.length, key.length-1) != '_'){
            var key = key + '_';
        }
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

//????????? ?????????????????? ??????
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
//  ???????????? ??????????????? ??????
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
        url: "/api/ajax/ajax_getshopNew.asp",
        data: {data: JSON.stringify(addrdata)},
        dataType: "json",
        success: function(res) {
            if(res.result == "0000") {
                if(res.online_status != "Y") {
                    showAlertMsg({msg:"???????????? ????????? ?????? ????????? ????????? ??????????????? ????????? ?????? ????????????."});
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
							showAlertMsg({msg:"????????? ????????? ??????????????????."});
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
                showAlertMsg({msg:"??????????????? ????????? ????????????."});
            }
            // if(res != "") {
            //     var rv = res.split(",");

            //     if(rv[1] == "Y") {
            //         getDeliveryShopInfo(rv[2]);
            //     } else {
            //         alert("?????? ????????? ??????????????? ????????? ??? ????????????.");
            //     }
            // } else {
            //     alert("??????????????? ????????? ????????????.");
            // }
        },
        error: function(xhr) {
            showAlertMsg({msg:"??????????????? ????????? ????????????."});
        }
    });
}

function checkDeliveryShop_new(addrdata, page_type) {
	console.log(6)
	console.log(JSON.stringify(addrdata))
    $.ajax({
        method: "post",
        url: "/api/ajax/ajax_getshopNew.asp",
        data: {data: JSON.stringify(addrdata)},
        dataType: "json",
        success: function(res) {
			console.log(res);

            if(sessionStorage.getItem("M_1695_0_") || sessionStorage.getItem("M_1696_0_")){
            }else{
                if (res.result != "0000") {
                    alert(res.message);
                    return false;
                }
            }

			if (page_type == "TOP") {
				var_branch_data = JSON.stringify(res);
				var_branch_id = res.branch_id;
				var_branch_name = res.branch_name;

				var_order_type = "D";
			} else {
				$("#branch_data").val(JSON.stringify(res));
				$("#branch_id").val(res.branch_id);
				$("#branch_name").text(res.branch_name);

				$("#order_type").val("D");
			}
			
			//?????????????????? 2020-08-26
			getDeliveryShopInfo_hill(res.branch_id);

			if (typeof(next_page_gubun) != "undefined" && next_page_gubun != "" && next_page_gubun != null) {
				if (next_page_gubun == "D") {
					go_next_page_map(next_page_gubun);
				}
			} else {
			}
        },
        error: function(xhr) {
			console.log(xhr);
			console.log(xhr.message);
            showAlertMsg({msg:"?????? ????????? ????????? ???????????? ????????????."});
        }
    });
}

//2020-08-25 ???????????? ?????? ??????
function getDeliveryShopInfo_hill(br_id) {

	 $.ajax({
		 method: "post",
		 url: "/api/ajax/ajax_getStoreInfo.asp",
		 data: {branch_id: br_id},
		 dataType: "json",
		 success: function(res) {
			if(res.add_price_yn == "Y"){
//				showAlertMsg({msg:"????????? ??? ??????????????? ????????? ?????? ??????????????? ????????? ??? ????????????."});
				alert("????????? ??? ??????????????? ????????? ?????? ??????????????? ????????? ??? ????????????.");
			}
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

function selectShipAddress_new(addr_idx, page_type) {
    if(addr_idx == 0) { //????????? ???????????? ????????? ??????
		console.log(5);
		console.log(getTempAddress());
		console.log(page_type);
        drawShipAddress_new(getTempAddress(), page_type);
    } else { // ????????? ???????????? ????????? ??????
        $.ajax({
            method: "post",
            url: "/api/ajax/ajax_getAddress.asp",
            data: {"addr_idx": addr_idx},
            dataType: "json",
            success: function(data) {
				console.log(4);
				console.log(data[0]);
				console.log(page_type);

				if (typeof(document.get_juso_form) != "undefined" && document.get_juso_form != "" && document.get_juso_form != null) 
				{
					document.get_juso_form.keyword.value = data[0].address_road;

					$.ajax({
						url:juso_api_url
						,type:"post"
						,data:$("#get_juso_form").serialize()
						,dataType:"jsonp"
						,crossDomain:true
						,success:function(jsonStr){
							var errCode = jsonStr.results.common.errorCode;
							var errDesc = jsonStr.results.common.errorMessage;

							if(errCode != "0"){
								alert(errCode+"="+errDesc);
							}else{
								if(jsonStr != null){

									$(jsonStr.results.juso).each(function(){

										document.xy_form.admCd.value = this.admCd;
										document.xy_form.rnMgtSn.value = this.rnMgtSn;
										document.xy_form.udrtYn.value = this.udrtYn;
										document.xy_form.buldMnnm.value = this.buldMnnm;
										document.xy_form.buldSlno.value = this.buldSlno;

									});

									$.ajax({
										url:juso_api_xy_url
										,type:"post"
										,data:$("#xy_form").serialize()
										,dataType:"jsonp"
										,crossDomain:true
										,success:function(jsonStr){
											var errCode = jsonStr.results.common.errorCode;
											var errDesc = jsonStr.results.common.errorMessage;
											if(errCode != "0"){
												alert(errCode+"="+errDesc);
											}else{
												if(jsonStr != null){

													var grs80 = new Proj4js.Proj("EPSG:5179");
													var wgs84 = new Proj4js.Proj("EPSG:4326");

													var lat = jsonStr.results.juso[0].entY;
													var lng = jsonStr.results.juso[0].entX;

													var p = new Proj4js.Point(lng, lat);

													Proj4js.transform(grs80, wgs84, p);

													lat = p.y.toFixed(6) +'0'; // 6?????? ?????? ?????? 7?????? 0 ?????? (??? 7??????????????? ??????.)
													lng = p.x.toFixed(6) +'0'; // 6?????? ?????? ?????? 7?????? 0 ?????? (??? 7??????????????? ??????.)

													data[0].lat = lat;
													data[0].lng = lng;

									                drawShipAddress_new(data[0], page_type);

												} else {
													alert("????????????");
													return false;
												}
											}
										}
										,error: function(xhr,status, error){
											alert("????????????");
											return false;
										}
									});
								} else {
									alert("????????????");
									return false;
								}
							}
						}
						,error: function(xhr,status, error){
							alert("????????????");
							return false;
						}
					});
				} else {
	                drawShipAddress_new(data[0], page_type);
				}
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

//selectCoordHCode(?????????, ????????? addr_idx, ?????? ?????????, ?????? ?????? ?????? param)
function selectCoordHCode(mode, addr_idx, query, param){
	var err_msg = "????????? ?????? ?????? ??? ?????? ??????";
	var h_code = "";
	
	// 1. ?????? ????????? 
	if(query != ""){ 
		// 2. kakao api key ???????????? 
		$.ajax({
			url : "/api/ajax/ajax_getCoordApiKey.asp",
			dataType: "json"
		})
		.done(function(res_ak){
			if(res_ak.hasOwnProperty("result") && res_ak.result == 0) {
				// 3. ?????? ???????????? ?????? ?????? ????????????
				$.ajax({
					url :"https://dapi.kakao.com/v2/local/search/address.json?query="+ query +"&page=1&size=1"+""
					,type: "GET"
					,beforeSend: function (xhr) {
						xhr.setRequestHeader("Content-type", "application/json");
						xhr.setRequestHeader("Authorization", "KakaoAK " + res_ak.message);
					}
				})
				.done(function(res){
					if(res.hasOwnProperty("meta") && res.hasOwnProperty("documents")) { //?????? ????????? ?????? ??? 
						if(res.documents[0].hasOwnProperty("address") && res.documents[0].address.hasOwnProperty("h_code")){ // ??????????????? ?????? ?????? ??? 
							err_msg = ""; //?????? ??????
							h_code = res.documents[0].address.h_code;
							lat = res.documents[0].address.y;
							lng = res.documents[0].address.x;
														
							// 4. ?????? ?????? ????????? ??????????????? ???????????? 
							if(h_code != ""){
                                if(typeof(param) == 'object' && param.prop('tagName')=="INPUT") { //????????? ?????? form??? ??????
                                    $(param).val(h_code);
                                    $("#form_addr input[name=lat]").val(String(lat).substr(0,10));
                                    $("#form_addr input[name=lng]").val(String(lng).substr(0,11));                                }
								if(addr_idx != "" && addr_idx > 0){
									var err_msg2 = "????????? ?????? ?????? ??????";
									$.ajax({
										method: "post",
										data: {"addr_idx": addr_idx, "h_code": h_code},
										url : "/api/ajax/ajax_saveMemberAddressHCode.asp",
										dataType: "json"
									})
									.done(function(res_save){
										if(res_save.hasOwnProperty("result") && res_save.result == 0){
											err_msg2 = ""; //?????? ??????
											
										}else{
											err_msg2 = res_save.message; //?????? ??????
										}
									})
									.fail(function(xhr, status, error) {
										if(xhr) {
											err_msg2 += '<br>' + xhr.status + ' ' + error
										}
									})
									.always(function(){
										if(err_msg2 != ""){
											showAlertMsg({msg:err_msg2});
										}else{
											//h_code ?????? ??? mode??? ????????? ?????? ?????? ??????
											if(mode=="S"){ //?????? ?????? ????????? ???????????? ????????? ?????????
												addr_img_control(addr_idx, param);
											}
                                            if(mode=="Y"){ //???????????????-??????
                                                validAddress();
                                            }
                                            if(mode=="N"){ //???????????????-?????????
                                                validAddressNoMember();
                                            }
										}
									});
								}else{  
                                    if(mode=="Y"){ //???????????????-??????
                                        validAddress();
                                    }
                                    if(mode=="N"){ //???????????????-?????????
                                        validAddressNoMember();
                                    }
                                }
							}
						} 
					} else if(res.hasOwnProperty("msg")){ //????????? ?????? msg??? ?????? ??? 
						err_msg += '<br>' + res.msg;
					}
				})
				.fail(function(xhr, status, error) {
					if(xhr) {
						err_msg += '<br>' + xhr.status + ' ' + error
						if(xhr.hasOwnProperty("responseText")){
							var err_json = JSON.parse(xhr.responseText)
							if(err_json.hasOwnProperty("msg"))
								err_msg += '<br>' + err_json.msg
						}
					}
				})
				.always(function(){
					if(err_msg != ""){
						showAlertMsg({msg:err_msg});
					}
				});
			}else{
				showAlertMsg({msg:'?????????(AP) ?????? ??? ?????? ??????'});
			}
		})
		.always(function() {
			
		})
		.fail(function(xhr, status, error) {
			if(xhr) {
				showAlertMsg({msg:'?????????(AP) ?????? ??? ?????? ??????<br>' + xhr.status + ' ' + error});
			}
		});
						
						
	}else{
		showAlertMsg({msg:'????????? ?????? ?????????????????????.'});
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
			alert("???????????? ???????????????"); 
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
            if (res.url.substring(0,7) == "http://"){
                window.open(res.url);
            }else{
                if (res.result == "1"){
                    f.target = "_self";
                }else if (res.result == "2"){
                    f.target = "_self";
                }else if (res.result == "3"){
                    f.target = "_blank";
                }else{
                    showAlertMsg({msg:'??????????????????.'});
                    return;
                }

                f.action = res.url;
                f.submit();
            }
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

	$('#pay_amount_new').html(addCommas(tot_price) +"???");
}

function control_menu_qty(num)
{
	var OnlyNumber = /^[0-9]+$/
	var qty = Number($('#new_qty_'+ current_menu_key).val());

	// ????????? ?????????
	if (OnlyNumber.test(qty) == false) {
		$('#new_qty_'+ current_menu_key).val(0);
	} else {
		// ????????? 1?????? / -?????? 
		if (qty <= 1 && num == -1) {
			$('#new_qty_'+ current_menu_key).val(1);
		} else {
			$('#new_qty_'+ current_menu_key).val(qty+num);
		}
	}

	view_price();
}

function goAddCart(key, value)
{
    // for (let i=0; i<subCartList.length; i++) {
        removeCartMenu(key);
        removeCartSideAll(key);
        var qty = Number($('#new_qty_'+ key).val());
        // alert(qty);

        addCartMenu(value);
        changeTxtMenuQty(key, qty);
    // }


	// $('.side_hide_class').each(function(){
	// 	addCartSide(current_menu_key, $(this).val());

	// 	item = $(this).val().split("$$");
	// 	skey = item[0]+"_"+item[1]+"_"+item[2];

	// 	changeTxtSideQty(current_menu_key, skey, qty);
	// });
}

function goAddCart_Recom(current_menu_key, menuItem)
{
	// alert(current_menu_key);
    AddSubCart(current_menu_key, menuItem);

    // removeCartMenu(current_menu_key);
	// removeCartSideAll(current_menu_key);
	var qty = Number($('#new_qty_'+ current_menu_key).val());

	// addCartMenu(menuItem);
	changeTxtMenuQty(current_menu_key, qty);

	// $('#recom_div_'+ current_menu_key).remove();

	getView();

	// $( 'html, body' ).animate( { scrollTop : 0 }, 700 ); // ????????? ??????
}

function goAddCart_side(current_menu_key, menuItem)
{
    if (current_menu_key.substring(current_menu_key.length, current_menu_key.length-1) != '_'){
        var current_menu_key = current_menu_key + '_';
    }

    cart_key = sessionStorage.getItem(current_menu_key)

	if (typeof(cart_key) != "undefined" && cart_key != "" && cart_key != null) {
		showAlertMsg({msg:"?????? ??????????????? ?????? ???????????????.<br/>????????? ??????????????????."})
	} else {
		removeCartMenu(current_menu_key);
		removeCartSideAll(current_menu_key);
		var qty = 1;

		addCartMenu(menuItem);
		changeTxtMenuQty(current_menu_key, qty);

		getView();

		showAlertMsg({msg:"??????????????? ????????? ???????????????."})
	}

	$( 'html, body' ).animate( { scrollTop : 0 }, 700 ); // ????????? ??????
}

function goCartTxt_Recom(key, num)
{
	var qty = Number($('#new_qty_'+ key).val());

	if (qty <= 1 && num == -1) {
		return;
	}

	$('#new_qty_'+ key).val(qty + num);
}

function goCart()
{
	var ds = document.getElementById("detail_cart").style.display;

    if (ds == "block"){
        var a = 'Y';
        for (let i=0; i<subCartList.length; i++) {

            var key = subCartList[i].key;
            if (key.substring(key.length, key.length-1) != '_'){
                var key = key + '_';
            }
            // alert(key);
        
            cart_key = sessionStorage.getItem(key);
            // alert(sessionStorage.getItem(key));
        
            if (typeof(cart_key) != "undefined" && cart_key != "" && cart_key != null) {
                // alert('notnull');
                a = 'N';
                var qty = Number($('#new_qty_'+ key).val());
                changeTxtMenuQty(key, qty);
            } else{
                // alert('null');
                goAddCart(key, subCartList[i].value);
            }
        }

        if (a == 'N') {
            // $('#lp_alert .btn-wrap').hide(0);
            $('#lp_alert .btn_lp_close').hide(0);
            // $('#lp_alert .lp-confirm-cont').css('padding','20px 20px 0');
    
            showAlertMsg({msg:"?????? ??????????????? ?????? ???????????????.<br/>??????????????? ???????????????."});
			$('#lp_alert .btn-wrap').on("click",function() {
                // setTimeout("location.href='/order/cart.asp'", 800);
				location.href = "/order/cart.asp";
			});
        } else{
            $('#lp_alert .btn-wrap').hide(0);
            $('#lp_alert .btn_lp_close').hide(0);
            $('#lp_alert .lp-confirm-cont').css('padding','20px 20px 0');

            showAlertMsg({msg:"??????????????? ???????????????"});

            setTimeout("history.back()", 800);

            history.back();
        }
    } else{
		document.getElementById("footer_more").click();
    }
}

function goOrder()
{
	var ds = document.getElementById("detail_cart").style.display;

    if (ds == "block"){
        var a = 'Y';
        for (let i=0; i<subCartList.length; i++) {

            var key = subCartList[i].key;
            if (key.substring(key.length, key.length-1) != '_'){
                var key = key + '_';
            }
        
            cart_key = sessionStorage.getItem(key);

            if (typeof(cart_key) != "undefined" && cart_key != "" && cart_key != null) {
                a = 'N';
                var qty = Number($('#new_qty_'+ key).val());
                changeTxtMenuQty(key, qty);
            } else{
                goAddCart(key, subCartList[i].value);
            }
        }

        if (a == 'N') {
            // $('#lp_alert .btn-wrap').hide(0);
            $('#lp_alert .btn_lp_close').hide(0);
            // $('#lp_alert .lp-confirm-cont').css('padding','20px 20px 0');
    
            showAlertMsg({msg:"?????? ??????????????? ?????? ???????????????. ??????????????? ???????????????."});
            $('#lp_alert .btn-wrap').on("click",function() {
				location.href = "/order/cart.asp";
			});
        } else{   
            // setTimeout("location.href='/order/cart.asp'", 800);
            location.href = "/order/cart.asp";
        }

    } else{
		document.getElementById("footer_more").click();
    }
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

function sessionStorageException(key)
{
    if(key == null) return false;
    if(key == ta_id) return false;
//	if(key != ta_id) return false;
	if(key.substring(0, 3) == "ss_") return false;
	if(key.substring(0, 3) == "ec_") return false;
	if(key == "ENP_SESSION_KEY") return false;
    
	if(key == "ENP_KEYWORD") return false; // ???????????? ?????????
	if(key == "savefrom-helper-extension") return false;
}

function change_store_cart(br_id)
{
	/*****************************************************/
	// ???????????? > ??????????????? ??????????????? ??????.
	// ?????? ??? ????????? ????????????.
	/*****************************************************/

//	// ?????? ?????? ????????? ???????????? ?????? ??????.
//	var cc = getAllCartMenuCount();
//
//	// e-??????????????? ??????.
//	// e-?????? > ???????????? ????????? msg > ??????????????? ?????? ?????? ????????????!
//	if (sessionStorage.getItem("ss_branch_id") != "" && typeof(sessionStorage.getItem("ss_branch_id")) != "undefined" && sessionStorage.getItem("ss_branch_id") != "" && sessionStorage.getItem("ss_branch_id") != null) {
//		if (cc>0 && sessionStorage.getItem("ss_branch_id") != br_id) 
//		{
//			alert("??????????????? ??????????????? ??????????????? ???????????????.");
//
//			if(supportStorage()) {
//				var len = sessionStorage.length
//				var key_arr = new Array();
//				var j=0;
//
//				for(var i = 0; i < len; i++) {
//					var key = sessionStorage.key(i);
//
//					if (key != "" && typeof(key) != "undefined" && key != "" && key != null) {
//						if(key == null) continue;
//						if(key == ta_id) continue;
//						if(key.substring(0, 3) == "ss_") continue;
//
//						key_arr[j] = key;
//						j++;
//					} else {
//					}
//				}
//
//				for(var i = 0; i < key_arr.length; i++) {
//					if (key_arr[i] != "" && typeof(key_arr[i]) != "undefined" && key_arr[i] != "" && key_arr[i] != null) {
//						sessionStorage.removeItem(key_arr[i]);
//					}
//				}
//			}
//		}
//	}
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
//	// ????????? ?????????
//	if (OnlyNumber.test(qty) == false) {
//		$('#qty_'+ current_menu_key).val(0);
//	} else {
//		// ????????? 0?????? / -??? ????????????
//		if (qty == 0 && str != -1) {
//			addCartMenu(menuDate);
//		} else {
//			// ????????? 1?????? / -?????? 
//			if (str == -1 && qty == 1) {
//				removeCartMenu(current_menu_key);
//				$('#qty_'+ current_menu_key).val(0);
//
//				// ??????????????? ?????????
//				$('.side_class').each(function(){
//					$(this).prop("checked", false);
//				});
//			} else {
//				changeMenuQty(current_menu_key, str);
//
//				// ?????????????????? ?????? ??????
//				$('.hide_side').each(function(){
//					changeSideQty(current_menu_key, $(this).val(), str);
//				})
//			}
//		}
//	}
//}

function goAddSubCart_side(current_menu_key, menuItem)
{
    if(supportStorage()) {
		menuItem += "$$";	//?????? ??????
        var item = menuItem.split("$$");

        var key = item[0]+"_"+item[1]+"_"+item[2]+"_"+item[6];
        // alert(key);
        // return false;

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
            jdata.kindSel = item[7];
            jdata.side = {};
            saveCartMenu(key, JSON.stringify(jdata));
        }

        chkCartMenuCount();
        // var item = JSON.parse(data);
        getView();
    }
	// cart_key = sessionStorage.getItem(current_menu_key);

    // sessionStorage.setItem(current_menu_key, current_menu_key);
    // alert(cart_key);
    removeCartMenu(current_menu_key);
    removeCartSideAll(current_menu_key);
    var qty = 1;

    addCartSide(current_menu_key, menuItem);
    changeTxtMenuQty(current_menu_key, qty);

    getView();

    // showAlertMsg({msg:"??????????????? ????????? ???????????????."})
}

function removeSubCartMenu(key) {
    const div = document.getElementById("detail_cart_inner_"+key);
    div.remove();

    var chk = document.getElementById("chkbox_"+key).checked;

    if (chk == true){
        document.getElementById("chkbox_"+key).checked = false;
    }
    // alert(key);
    removeCartMenu(key);
    for (let i = 0; i < subCartList.length; i++) {
        if (subCartList[i].key === key) {
            subCartList.splice(i,1);
            i--;
        }
    }
    // console.log(subCartList);
}

function control_submenu_qty(menu_key, num)
{
	var OnlyNumber = /^[0-9]+$/
	var qty = Number($('#new_qty_'+ menu_key).val());

	// ????????? ?????????
	if (OnlyNumber.test(qty) == false) {
		$('#new_qty_'+ menu_key).val(0);
	} else {
		// ????????? 1?????? / -?????? 
		if (qty <= 1 && num == -1) {
			$('#new_qty_'+ menu_key).val(1);
		} else {
			$('#new_qty_'+ menu_key).val(qty+num);
		}
	}

	// view_price();
}
