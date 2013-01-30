var camera;
var container;
var height;
var mouse = new THREE.Vector2();
var projector;
var radius;
var renderer;
var rotationSpeed;
var scale_multiplier = 1.00002;
var scene;
var socket;
var width;
var INTERSECTED, SELECTED;

var current_rates;
var current_time = new Date();

var instruments = [ "AUD_CAD","AUD_CHF","AUD_HKD","AUD_JPY","AUD_NZD","AUD_SGD","AUD_USD","CAD_CHF","CAD_HKD","CAD_JPY","CAD_SGD","CHF_HKD","CHF_JPY","CHF_ZAR","EUR_AUD","EUR_CAD","EUR_CHF","EUR_CZK","EUR_DKK","EUR_GBP","EUR_HKD","EUR_HUF","EUR_JPY","EUR_NOK","EUR_NZD","EUR_PLN","EUR_SEK","EUR_SGD","EUR_TRY","EUR_USD","EUR_ZAR","GBP_AUD","GBP_CAD","GBP_CHF","GBP_HKD","GBP_JPY","GBP_NZD","GBP_PLN","GBP_SGD","GBP_USD","GBP_ZAR","HKD_JPY","NZD_CAD","NZD_CHF","NZD_HKD","NZD_JPY","NZD_SGD","NZD_USD","SGD_CHF","SGD_HKD","SGD_JPY","TRY_JPY","USD_CAD","USD_CHF","USD_CNY","USD_CZK","USD_DKK","USD_HKD","USD_HUF","USD_INR","USD_JPY","USD_MXN","USD_NOK","USD_PLN","USD_SAR","USD_SEK","USD_SGD","USD_THB","USD_TRY","USD_TWD","USD_ZAR","XAG_AUD","XAG_CAD","XAG_CHF","XAG_EUR","XAG_GBP","XAG_HKD","XAG_JPY","XAG_NZD","XAG_SGD","XAG_USD","XAU_AUD","XAU_CAD","XAU_CHF","XAU_EUR","XAU_GBP","XAU_HKD","XAU_JPY","XAU_NZD","XAU_SGD","XAU_USD","XAU_XAG","XPD_USD","XPT_USD","ZAR_JPY" ];
var currency_pairs = {
    "AUD_CAD": { "group": 1, "color": "EDC791", "render": true, "mesh": "" },
    "AUD_CHF": { "group": 1, "color": "E6B778", "render": true, "mesh": "" },
    "AUD_HKD": { "group": 1, "color": "DFA860", "render": true, "mesh": "" },
    "AUD_JPY": { "group": 1, "color": "D89948", "render": true, "mesh": "" },
    "AUD_NZD": { "group": 1, "color": "D18A30", "render": true, "mesh": "" },
    "AUD_SGD": { "group": 1, "color": "CA7B18", "render": true, "mesh": "" },
    "AUD_USD": { "group": 1, "color": "C46C00", "render": true, "mesh": "" },
    "CAD_CHF": { "group": 2, "color": "D38BF7", "render": true, "mesh": "" },
    "CAD_HKD": { "group": 2, "color": "A85DCE", "render": true, "mesh": "" },
    "CAD_JPY": { "group": 2, "color": "7E2FA5", "render": true, "mesh": "" },
    "CAD_SGD": { "group": 2, "color": "54017D", "render": true, "mesh": "" },
    "CHF_HKD": { "group": 3, "color": "FF7FC5", "render": true, "mesh": "" },
    "CHF_JPY": { "group": 3, "color": "DB3F95", "render": true, "mesh": "" },
    "CHF_ZAR": { "group": 3, "color": "B80065", "render": true, "mesh": "" },
    "EUR_AUD": { "group": 4, "color": "F2A7A7", "render": true, "mesh": "" },
    "EUR_CAD": { "group": 4, "color": "EB9C9C", "render": true, "mesh": "" },
    "EUR_CHF": { "group": 4, "color": "E59292", "render": true, "mesh": "" },
    "EUR_CZK": { "group": 4, "color": "DE8787", "render": true, "mesh": "" },
    "EUR_DKK": { "group": 4, "color": "D87D7D", "render": true, "mesh": "" },
    "EUR_GBP": { "group": 4, "color": "D17272", "render": true, "mesh": "" },
    "EUR_HKD": { "group": 4, "color": "CB6868", "render": true, "mesh": "" },
    "EUR_HUF": { "group": 4, "color": "C45D5D", "render": true, "mesh": "" },
    "EUR_JPY": { "group": 4, "color": "BE5353", "render": true, "mesh": "" },
    "EUR_NOK": { "group": 4, "color": "B84949", "render": true, "mesh": "" },
    "EUR_NZD": { "group": 4, "color": "B13E3E", "render": true, "mesh": "" },
    "EUR_PLN": { "group": 4, "color": "AB3434", "render": true, "mesh": "" },
    "EUR_SEK": { "group": 4, "color": "A42929", "render": true, "mesh": "" },
    "EUR_SGD": { "group": 4, "color": "9E1F1F", "render": true, "mesh": "" },
    "EUR_TRY": { "group": 4, "color": "971414", "render": true, "mesh": "" },
    "EUR_USD": { "group": 4, "color": "910A0A", "render": true, "mesh": "" },
    "EUR_ZAR": { "group": 4, "color": "8B0000", "render": true, "mesh": "" },
    "GBP_AUD": { "group": 5, "color": "96B6FF", "render": true, "mesh": "" },
    "GBP_CAD": { "group": 5, "color": "85A6F1", "render": true, "mesh": "" },
    "GBP_CHF": { "group": 5, "color": "7597E3", "render": true, "mesh": "" },
    "GBP_HKD": { "group": 5, "color": "6587D5", "render": true, "mesh": "" },
    "GBP_JPY": { "group": 5, "color": "5478C7", "render": true, "mesh": "" },
    "GBP_NZD": { "group": 5, "color": "4468B9", "render": true, "mesh": "" },
    "GBP_PLN": { "group": 5, "color": "3459AB", "render": true, "mesh": "" },
    "GBP_SGD": { "group": 5, "color": "23499D", "render": true, "mesh": "" },
    "GBP_USD": { "group": 5, "color": "133A8F", "render": true, "mesh": "" },
    "GBP_ZAR": { "group": 5, "color": "032B82", "render": true, "mesh": "" },
    "NZD_CAD": { "group": 6, "color": "9EF2EE", "render": true, "mesh": "" },
    "NZD_CHF": { "group": 6, "color": "7FD5D0", "render": true, "mesh": "" },
    "NZD_HKD": { "group": 6, "color": "60B8B3", "render": true, "mesh": "" },
    "NZD_JPY": { "group": 6, "color": "419B96", "render": true, "mesh": "" },
    "NZD_SGD": { "group": 6, "color": "217E79", "render": true, "mesh": "" },
    "NZD_USD": { "group": 6, "color": "03615C", "render": true, "mesh": "" },
    "SGD_CHF": { "group": 7, "color": "FEFFA8", "render": true, "mesh": "" },
    "SGD_HKD": { "group": 7, "color": "E5E754", "render": true, "mesh": "" },
    "SGD_JPY": { "group": 7, "color": "CCCF00", "render": true, "mesh": "" },
    "USD_CAD": { "group": 8, "color": "ADFF2F", "render": true, "mesh": "" },
    "USD_CHF": { "group": 8, "color": "A3F52C", "render": true, "mesh": "" },
    "USD_CNY": { "group": 8, "color": "9AEB2A", "render": true, "mesh": "" },
    "USD_CZK": { "group": 8, "color": "90E227", "render": true, "mesh": "" },
    "USD_DKK": { "group": 8, "color": "87D825", "render": true, "mesh": "" },
    "USD_HKD": { "group": 8, "color": "7DCE22", "render": true, "mesh": "" },
    "USD_HUF": { "group": 8, "color": "74C520", "render": true, "mesh": "" },
    "USD_INR": { "group": 8, "color": "6ABB1D", "render": true, "mesh": "" },
    "USD_JPY": { "group": 8, "color": "61B21B", "render": true, "mesh": "" },
    "USD_MXN": { "group": 8, "color": "58A819", "render": true, "mesh": "" },
    "USD_NOK": { "group": 8, "color": "4E9E16", "render": true, "mesh": "" },
    "USD_PLN": { "group": 8, "color": "459514", "render": true, "mesh": "" },
    "USD_SAR": { "group": 8, "color": "3B8B11", "render": true, "mesh": "" },
    "USD_SEK": { "group": 8, "color": "32820F", "render": true, "mesh": "" },
    "USD_SGD": { "group": 8, "color": "28780C", "render": true, "mesh": "" },
    "USD_THB": { "group": 8, "color": "1F6E0A", "render": true, "mesh": "" },
    "USD_TRY": { "group": 8, "color": "156507", "render": true, "mesh": "" },
    "USD_TWD": { "group": 8, "color": "0C5B05", "render": true, "mesh": "" },
    "USD_ZAR": { "group": 8, "color": "035203", "render": true, "mesh": "" },
    "HKD_JPY": { "group": 9, "color": "FAF8DC", "render": true, "mesh": "" },
    "TRY_JPY": { "group": 9, "color": "D0B6B3", "render": true, "mesh": "" },
    "ZAR_JPY": { "group": 9, "color": "A6748B", "render": true, "mesh": "" },
    "XAG_AUD": { "group": 10, "color": "CCCCCC", "render": true, "mesh": "" },
    "XAG_CAD": { "group": 10, "color": "C2C2C2", "render": true, "mesh": "" },
    "XAG_CHF": { "group": 10, "color": "B9B9B9", "render": true, "mesh": "" },
    "XAG_EUR": { "group": 10, "color": "AFAFAF", "render": true, "mesh": "" },
    "XAG_GBP": { "group": 10, "color": "A6A6A6", "render": true, "mesh": "" },
    "XAG_HKD": { "group": 10, "color": "9C9C9C", "render": true, "mesh": "" },
    "XAG_JPY": { "group": 10, "color": "939393", "render": true, "mesh": "" },
    "XAG_NZD": { "group": 10, "color": "898989", "render": true, "mesh": "" },
    "XAG_SGD": { "group": 10, "color": "808080", "render": true, "mesh": "" },
    "XAG_USD": { "group": 10, "color": "777777", "render": true, "mesh": "" },
    "XAU_AUD": { "group": 10, "color": "F7D281", "render": true, "mesh": "" },
    "XAU_CAD": { "group": 10, "color": "F0C974", "render": true, "mesh": "" },
    "XAU_CHF": { "group": 10, "color": "E9C168", "render": true, "mesh": "" },
    "XAU_EUR": { "group": 10, "color": "E3B85C", "render": true, "mesh": "" },
    "XAU_GBP": { "group": 10, "color": "DCB050", "render": true, "mesh": "" },
    "XAU_HKD": { "group": 10, "color": "D6A844", "render": true, "mesh": "" },
    "XAU_JPY": { "group": 10, "color": "CF9F37", "render": true, "mesh": "" },
    "XAU_NZD": { "group": 10, "color": "C8972B", "render": true, "mesh": "" },
    "XAU_SGD": { "group": 10, "color": "C28E1F", "render": true, "mesh": "" },
    "XAU_USD": { "group": 10, "color": "BB8613", "render": true, "mesh": "" },
    "XAU_XAG": { "group": 10, "color": "B57E07", "render": true, "mesh": "" },
    "XPD_USD": { "group": 10, "color": "cacbd9", "render": true, "mesh": "" },
    "XPT_USD": { "group": 10, "color": "8d8e96", "render": true, "mesh": "" }
};

function init() {
    var geometry, material;
    scene = new THREE.Scene();

    //camera = new THREE.OrthographicCamera( -width, width, height, -height, -50000, 50000 );
    //camera.position.set( 0, 200, 200 );
    camera = new THREE.PerspectiveCamera( 45, width / height, 1, 10000 );
    camera.position.set( 0, 950, 850 );
    scene.add( camera );

    var ambientLight = new THREE.AmbientLight( 0x060606 );
    scene.add( ambientLight );

    var directionalLight = new THREE.DirectionalLight( 0xffffff );
    directionalLight.position.x = -500;
    directionalLight.position.y = 300;
    directionalLight.position.z = -300;
    directionalLight.position.normalize();
    scene.add( directionalLight );

    directionalLight = new THREE.DirectionalLight( 0xffffff );
    directionalLight.position.x = 800;
    directionalLight.position.y = 100;
    directionalLight.position.z = 500;
    directionalLight.position.normalize();
    scene.add( directionalLight );

    var x = -720;
    var z = -560;
    for ( var i in currency_pairs ) {
        geometry = new THREE.CubeGeometry( 100, 10, 100 );
        material = new THREE.MeshLambertMaterial({
            color: "0x" + currency_pairs[i].color,
            shading: THREE.FlatShading,
            overdraw: true,
            vertexColors: THREE.VertexColors
        });
        mesh = new THREE.Mesh( geometry, material );
        mesh.position = { "x": x, "y": 0, "z": z };
        if ( x < 720 ) {
            x += 140;
        }
        else {
            x = -720;
            z += 140;
        }
        mesh.currency_pair = i;
        scene.add( mesh );
        currency_pairs[i].mesh = mesh;
    }

    var previous_pair = "";
    var current_column = "";
    for ( var i in currency_pairs ) {
        var pair = currency_pairs[i];
        if ( !previous_pair || currency_pairs[previous_pair].group !== pair.group ) {
            current_column = $("<div />")
            .addClass("column")
            .appendTo("#legend");
        }
        var row = $("<div />")
        .addClass("row")
        .attr("id", "toggle_" + i);
        $("<div />")
        .addClass("marker")
        .css("background-color", "#" + pair.color)
        .appendTo(row);
        $("<div />")
        .addClass("label")
        .text(i.replace(/_/, '/'))
        .appendTo(row);
        row.appendTo(current_column);
        previous_pair = i;
    }

    projector = new THREE.Projector();

    renderer = new THREE.WebGLRenderer();
    renderer.setSize( width, height );

    $("#container").append( renderer.domElement );

    controls = new THREE.TrackballControls( camera, renderer.domElement );
    controls.rotateSpeed = 1.0;
    controls.zoomSpeed = 1.2;
    controls.panSpeed = 0.2;
    controls.noZoom = false;
    controls.noPan = false;
    controls.staticMoving = false;
    controls.dynamicDampingFactor = 0.3;
    controls.minDistance = radius * 1.1;
    controls.maxDistance = radius * 100;
    controls.keys = [ 65, 83, 68 ]; // [ rotateKey, zoomKey, panKey ]

    $(renderer.domElement).mousemove(on_canvas_mousemove);
    $(renderer.domElement).click(on_canvas_click);
    $(window).resize(onWindowResize);
}

function animate() {
    determine_rate_scales();
    requestAnimationFrame(animate);
    render();
}

function on_canvas_mousemove(event) {
    event.preventDefault();

    mouse.x = ( event.clientX / width ) * 2 - 1;
    mouse.y = - ( event.clientY / height ) * 2 + 1;

    var vector = new THREE.Vector3( mouse.x, mouse.y, 0.5 );
    projector.unprojectVector( vector, camera );

    var ray = new THREE.Ray( camera.position, vector.subSelf( camera.position ).normalize() );
    var intersects = ray.intersectObjects( scene.children );
    if ( intersects.length > 0 ) {
        if ( INTERSECTED != intersects[ 0 ].object ) {
            if ( INTERSECTED ) INTERSECTED.material.color.setHex( "0x" + currency_pairs[INTERSECTED.currency_pair].color );
            INTERSECTED = intersects[ 0 ].object;
            INTERSECTED.material.color.setHex( 0xff0000 );
        }
        $(renderer.domElement).css("cursor", "pointer");
    }
    else {
        if ( INTERSECTED ) INTERSECTED.material.color.setHex( "0x" + currency_pairs[INTERSECTED.currency_pair].color );
        INTERSECTED = null;
        $(renderer.domElement).css("cursor", "auto");
    }
}

function on_canvas_click(event) {
    var vector = new THREE.Vector3( mouse.x, mouse.y, 1 );
    projector.unprojectVector( vector, camera );

    var ray = new THREE.Ray( camera.position, vector.subSelf( camera.position ).normalize() );
    var intersects = ray.intersectObjects( scene.children );
    if ( intersects.length > 0 ) {
        var mesh = intersects[0].object;
        toggle_pair(mesh.currency_pair);
        INTERSECTED = null
    }
}

function onWindowResize( event ) {
        height = $("#container").innerHeight();
        width  = $("#container").innerWidth();
        renderer.setSize( width, height );
        camera.aspect = width / height;
        camera.updateProjectionMatrix();
        controls.screen.width = width;
        controls.screen.height = height;
        camera.radius = ( width + height ) / 4;
};

function render() {
    for ( i in currency_pairs ) {
        var pair = currency_pairs[i];
        if ( pair.render ) {
            // reset the color if the pair had previously been disabled
            if ( typeof(pair.color_temp) == "object" ) {
                pair.mesh.material.color = pair.color_temp;
                pair.color_temp = '';
            }
            if ( pair.scale_step ) {
                if ( pair.mesh.scale.y === pair.target_scale ) {
                    pair.scale_step = 0;
                    continue;
                }
                else if ( (pair.mesh.scale.y + pair.scale_step) < 0 ) {
                    pair.target_scale = 0.1;
                    pair.mesh.scale.y = 0.1;
                    pair.scale_step = 0;
                }
                else if ( (pair.scale_step > 0 && (pair.mesh.scale.y + pair.scale_step) > pair.target_scale) ||
                    (pair.scale_step < 0 && (pair.mesh.scale.y + pair.scale_step) < pair.target_scale)
                ) {
                    pair.mesh.scale.y = pair.target_scale;
                    pair.scale_step = 0;
                }
                else {
                    pair.mesh.scale.y += pair.scale_step;
                }
            }
            else if ( pair.target_scale < 0.1 ) {
                pair.mesh.scale.y = 0.1;
            }
        }
        else {
            if ( pair.mesh.material.color.r != 0.3 &&
                pair.mesh.material.color.g != 0.3 &
                pair.mesh.material.color.b != 0.3
            ) {
                pair.color_temp = pair.mesh.material.color;
                pair.mesh.material.color = { r: 0.3, g: 0.3, b: 0.3 };
            }
            pair.mesh.scale.y = 0.1;
        }
    }
    controls.update();
    renderer.render( scene, camera );
}

function determine_rate_scales() {
    for ( var i in currency_pairs ) {
        var pair = currency_pairs[i];
        var new_scale = rate_to_scale(pair);
        pair.target_scale = new_scale;
        var current_scale = pair.mesh.scale.y;
    
        if ( new_scale > current_scale) {
            pair.scale_step = (new_scale - current_scale) / 10;
        }
        else if ( new_scale < current_scale ) {
            pair.scale_step = -(current_scale - new_scale) / 10 ;
        }
        else {
            pair.scale_step = 0;
        }
    }
}

function rate_to_scale(pair) {
    var scale;
    var range = pair.bid_max_scale - pair.bid_min_scale;
    var step_size = range / 20;
    var steps = [];
    for ( var i = 1; i <= 20; i++ ) {
        step = {};
        step.scale = i;
        step.range = step_size * i;
        steps.push(step);
    }
    for ( var i = 0; i < 20 ; i++ ) {
        if ( pair.bid < ( pair.bid_min_scale + steps[i].range ) ) {
            return steps[i].scale;
        }
    }
    return 20;
}

function get_rates() {
    var new_time = new Date();
    var current_seconds = parseInt(current_time.getTime() / 1000);
    var new_seconds = parseInt(new_time.getTime() / 1000);
    if ( new_seconds > current_seconds ) {
        current_time = new_time;
        var quantity = Math.floor(Math.random()*95)+1;
        var pairs = {};
        var rates = [];
        var pair = instruments[Math.floor(Math.random()*95)];
        for ( var x = 0 ; x < quantity ; x++ ) {
            while ( typeof(pairs[pair]) !== "undefined" ) {
                var rand = Math.floor(Math.random()*95);
                pair = instruments[rand];
            }
            pairs[pair] = 1;
            var new_rate = [ pair, Math.floor(Math.random()*120000)+1 ];
            currency_pairs[pair].current_rate = new_rate;
            rates.push(new_rate);
        }
        return rates;
    }
    return null;
};

function toggle_pair(pair) {
    var el = $("#toggle_" + pair);
    if ( el.hasClass("disabled") ) {
        currency_pairs[pair].render = true;
        el.removeClass("disabled");
    }
    else {
        currency_pairs[pair].render = false;
        el.addClass("disabled");
    }
}

function websocket_connect(url) {
    if ( typeof(socket) !== "undefined" ) {
        socket.onclose = function () {};
        socket.close();
        $("#connection_status_msg").text("Disconnected");
    }
    socket = new WebSocket(url);

    socket.onopen = function() {
        $("#connection_status_msg").text("Connected");
    };

    socket.onmessage = function(e) {
        var data = JSON.parse(e.data);
        for ( var pair in data.rates ) {
            var pair_name = pair.replace("/", "_");
            if ( currency_pairs.hasOwnProperty(pair_name) ) {
                currency_pairs[pair_name].timestamp = data.rates[pair].timestamp;
                currency_pairs[pair_name].ask = data.rates[pair].ask;
                currency_pairs[pair_name].bid = data.rates[pair].bid;

                // bid change
                if ( typeof(currency_pairs[pair_name].bid_max) == "undefined" || currency_pairs[pair_name].bid_max < data.rates[pair].bid ) {
                    currency_pairs[pair_name].bid_max = data.rates[pair].bid;
                    var max_change = data.rates[pair].bid - currency_pairs[pair_name].bid_max;
                    currency_pairs[pair_name].bid_max_scale = (currency_pairs[pair_name].bid_max + max_change) * scale_multiplier;
                    currency_pairs[pair_name].bid_min_scale = (currency_pairs[pair_name].bid_min + max_change) * scale_multiplier;
                }
                if ( typeof(currency_pairs[pair_name].bid_min) == "undefined" || currency_pairs[pair_name].bid_min > data.rates[pair].bid ) {
                    currency_pairs[pair_name].bid_min = data.rates[pair].bid;
                    var min_change = currency_pairs[pair_name].bid_min - data.rates[pair].bid;
                    currency_pairs[pair_name].bid_max_scale = (currency_pairs[pair_name].bid_max - min_change) * scale_multiplier;
                    currency_pairs[pair_name].bid_min_scale = (currency_pairs[pair_name].bid_min - min_change) * scale_multiplier;
                }

                // ask change
                if ( typeof(currency_pairs[pair_name].ask_max) == "undefined" || currency_pairs[pair_name].ask_max < data.rates[pair].ask ) {
                    currency_pairs[pair_name].ask_max = data.rates[pair].ask;
                    var max_change = data.rates[pair].ask - currency_pairs[pair_name].ask_max;
                    currency_pairs[pair_name].ask_max_scale = (currency_pairs[pair_name].ask_max + max_change) * scale_multiplier;
                    currency_pairs[pair_name].ask_min_scale = (currency_pairs[pair_name].ask_min + max_change) * scale_multiplier;
                }
                if ( typeof(currency_pairs[pair_name].ask_min) == "undefined" || currency_pairs[pair_name].ask_min > data.rates[pair].ask ) {
                    currency_pairs[pair_name].ask_min = data.rates[pair].ask;
                    var min_change = currency_pairs[pair_name].ask_min - data.rates[pair].ask;
                    currency_pairs[pair_name].ask_max_scale = (currency_pairs[pair_name].ask_max - min_change) * scale_multiplier;
                    currency_pairs[pair_name].ask_min_scale = (currency_pairs[pair_name].ask_min - min_change) * scale_multiplier;
                }

                $("#toggle_" + pair_name).data("powertip", pair_name + " - " + currency_pairs[pair_name].timestamp + "<br /><br />Ask: " + currency_pairs[pair_name].ask + "<br />Min Ask: " + currency_pairs[pair_name].ask_min + "<br />Max Ask: " + currency_pairs[pair_name].ask_max + "<br /><br />Bid: " +  currency_pairs[pair_name].bid + "<br />Min Bid: " + currency_pairs[pair_name].bid_min + "<br />Max Bid: " + currency_pairs[pair_name].bid_max);
            }
        }
    };

    socket.onclose = function(e) {
        $("#connection_status_msg").text("Disconnected");
        setTimeout(function(){websocket_connect(url)}, 5000);
    };
}

$(document).ready(function() {
    radius = 1000;
    rotationSpeed = 0.1;
    height = $("#container").innerHeight();
    width  = $("#container").innerWidth();

    $("#legend").on("click", ".row", function() {
        var el   = $(this);
        var pair = el.text().replace(/\//, "_");
        if ( el.hasClass("disabled") ) {
            currency_pairs[pair].render = true;
            el.removeClass("disabled");
        }
        else {
            currency_pairs[pair].render = false;
            el.addClass("disabled");
        }
    });

    $("#base_currency_toggles").on("click", "button", function () {
        var base = $(this).text();
        for ( var i in currency_pairs ) {
            if ( base === "All") {
                currency_pairs[i].render = true;
                $("#toggle_" + i).removeClass("disabled");
            }
            else if ( base === "None" ) {
                currency_pairs[i].render = false;
                $("#toggle_" + i).addClass("disabled");
            }
            else {
                var re = new RegExp(base, "g");
                if ( re.test(i) ) {
                    currency_pairs[i].render = true;
                    $("#toggle_" + i).removeClass("disabled");
                }
                else {
                    currency_pairs[i].render = false;
                    $("#toggle_" + i).addClass("disabled");
                }
            }
        }
    });
    init();
    animate();

    var ws_path = "ws:ii9-dev:5000/rates";
    websocket_connect(ws_path);

    $(".row").powerTip({
        placement: 'ne'
    });
});
