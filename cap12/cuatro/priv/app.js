var juego;
var ws;
var color;

function dibuja(html) {
    $("#juego").html(html);
    $("#juego-msg").html("");
    $(".drop").on("click", function(event){
        var id = this.id.split("_")[1];
        send({type: "inserta", pos: parseInt(id)});
    });
}

function desconectado() {
    $(".drop").prop("disabled", true);
    $("#juego-msg").html("<h2>¡Desconectado!</h2>");
    $("#loginSection").css("display", "block");
}

function turno(quien) {
    $("#juego-msg").html("Turno de <strong>" + quien + "</strong>");
}

function gana(html, msg) {
    $("#juego").html(html);
    $(".drop").prop("disabled", true);
    $("#juego-msg").html("<h1>" + msg + "</h1>");
    $("#loginSection").css("display", "block");
}

function onLogin(result, quien) {
    if (result == "ok") {
        color = quien
        $("#loginSection").css("display", "none");
        $("#loginName").html(color);
        $("#loggedSection").css("display", "block");
        $("#juego-msg").html("<p>Esperando al otro jugador...</p>");
        send({type: "muestra"})
    } else {
        alert("error: " + result)
    }
}

function send(message) {
    if (juego) {
        message.juego = juego;
    }
    console.log("send: ", message);
    ws.send(JSON.stringify(message));
};

function connect() {
    const hostname = document.location.href.split("/", 3)[2];
    if (ws) {
        ws.close();
    }
    ws = new WebSocket("ws://" + hostname + "/websession");
    ws.onopen = function(){
        console.log("connected!");
        send({type: "login", juego: juego});
    };
    ws.onerror = function(message){
        console.error(message);
        desconectado();
    };
    ws.onclose = function() {
        desconectado();
    }
    ws.onmessage = function(message){
        console.log("Got message", message.data);
        var data = JSON.parse(message.data);

        switch(data.type) {
            case "login":
                onLogin(data.result, data.color);
                break;
            case "dibuja":
                dibuja(data.html);
                break;
            case "gana":
                gana(data.html, data.msg);
                break;
            case "turno":
                turno(data.quien);
                break;
            default:
                break;
        }
    };
}

$(document).ready(function(){
    $("#loginBtn").on("click", function(event){
        $("#juego").html("");
        juego = $("#loginInput").val();
        console.log("juego: ", juego);
        connect();
    });
});
