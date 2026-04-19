function getEl(id){
    return document.getElementById(id);
}

const mainCanvas = getEl("imageMain");
const canvasHolder = getEl("canvasHolder");

if (!mainCanvas.getContext)
    alert("Somehow, everything broke.");

const mainCtx = mainCanvas.getContext("2d");
const Ihelp = getEl("helptext");
const Iwidth = getEl("width");
const Iheight = getEl("height");
const Izoom = getEl("zoom");
const Icolor = getEl("color");
const Iacolor = getEl("altcolor");
const Ilayerbar = getEl("layerbar");
const Idrawing = getEl("drawing");
const Igridzoom = getEl("gridzoom");
const Ilayer = getEl("layerinput");
const Ilayermax = getEl("layercounter");

let global = 0;
let mousedown = false;

let width = 32;
let height = 32;
let zoom = 1;
let acts = [[]];
let showing = [true];
let redostack = [[]];
let undostack = [[]];
let layer = 0;
let layercount = 1;

let mPos = [-1, -1];
let gridOn = false;
let draw = true;

let backgroundLight = false;

let refreshLayers = true;

function help(){
    if (Ihelp.className.length > 0){
        Ihelp.className = "";
    }
    else{
        Ihelp.className = "hide";
    }
}

function tellmeyoursecrets(){
    alert(acts);
    alert(showing);
    alert(redostack);
    alert(undostack);
    alert(layer);
    alert(layercount);
}

function save(){
    drawZoom(1);
    window.location.href = mainCanvas.toDataURL("image/png").replace("image/png", "image/octet-stream");
}

function swapDraw(){
    draw = !draw;
}

function gridtoggle(){
    gridOn = !gridOn;
}

function zoomout(){
    if (zoom > 1)
        zoom *= 0.5;
}

function zoomin(){
    if (zoom < 64)
        zoom *= 2;
    else
        alert("Increasing the zoom higher may cause your tab to crash.");
}

function doAct(act, z){
    mainCtx.fillStyle = act[2];
    mainCtx.fillRect(act[0] * z, act[1] * z, z, z);
}

function doActLayer(act, ctx){
    ctx.fillStyle = act[2];
    ctx.fillRect(act[0], act[1], 1, 1);
}

function setPx(l, x, y, c){
    if(!acts[l][x]){
        acts[l][x] = [];
    }
    acts[l][x][y] = [x, y, c];
}

function getPx(l, x, y){
    if (!acts[l][x])
        return "#00000000";
    if (!acts[l][x][y])
        return "#00000000";
    return acts[l][x][y][2];
}

function addAct(t, x, y, c){
    if(!t)
        c = "#00000000";
    refreshLayers = true;
    undostack[layer].push([x, y, getPx(layer, x, y), c]);
    setPx(layer, x, y, c);
}

function getLayerButtons(i){
    return [getEl("layerLB"+i), getEl("layerRB"+i), getEl("layerRM"+i), getEl("layerSH"+i), getEl("layerSW"+i)];
}

function setFunctions(buttons, i){
    buttons[0].onmouseup = () => moveLayerLeft(i);
    buttons[1].onmouseup = () => moveLayerRight(i);
    buttons[2].onmouseup = () => removeLayer(i);
    buttons[3].onmouseup = () => {showing[i] = !showing[i]; refreshLayers = true;};
    buttons[4].onmouseup = () => {setLayer(i); refreshLayers = true;};
}

function updateLayerBar(){ // fuck
    if (!refreshLayers)
        return;
    refreshLayers = false;
    for (let i = 0; i < layercount; i++){
        let ourLayer = getEl("layer"+i);
        if(!ourLayer){
            ourLayer = document.createElement("span");
            ourLayer.width = width;
            ourLayer.id = "layer"+i;
            ourLayer.appendChild(document.createElement("canvas")).id = "layerC"+i;
            // ourLayer.appendChild(document.createElement("br"));
            let leftButton = ourLayer.appendChild(document.createElement("button"));
            let rightButton = ourLayer.appendChild(document.createElement("button"));
            // ourLayer.appendChild(document.createElement("br"));
            let remButton = ourLayer.appendChild(document.createElement("button"));
            // ourLayer.appendChild(document.createElement("br"));
            let showButton = ourLayer.appendChild(document.createElement("button"));
            // ourLayer.appendChild(document.createElement("br"));
            let switchButton = ourLayer.appendChild(document.createElement("button"));
            ourLayer.appendChild(document.createElement("br"));
            leftButton.id = "layerLB"+i;
            rightButton.id = "layerRB"+i;
            remButton.id = "layerRM"+i;
            showButton.id = "layerSH"+i;
            switchButton.id = "layerSW"+i;
            leftButton.appendChild(document.createTextNode("<"));
            rightButton.appendChild(document.createTextNode(">"));
            remButton.appendChild(document.createTextNode("Remove"));
            showButton.appendChild(document.createTextNode("Hide"));
            switchButton.appendChild(document.createTextNode("Switch"));
            setFunctions([leftButton, rightButton, remButton, showButton, switchButton], i);
        }
        Ilayerbar.appendChild(ourLayer);
        let ourCanvas = getEl("layerC"+i);
        ourCanvas.width = width;
        ourCanvas.height = height;
        if (i === layer)
            ourCanvas.className = "selected";
        else
            ourCanvas.className = "";

        if (!showing[i])
            ourCanvas.classList.add("hidden");
        let ourContext = ourCanvas.getContext("2d");
        ourContext.clearRect(0, 0, ourCanvas.width, ourCanvas.height);
        acts[i].forEach((x) => x.forEach((y) => doActLayer(y, ourContext)));
    }
}

function addLayer(){
    refreshLayers = true;
    acts.push([]);
    showing.push(true);
    redostack.push([]);
    undostack.push([]);
    layercount += 1;
}

function removeLayer(id){
    if(id === layer)
        return;
    refreshLayers = true;
    acts.splice(id, 1);
    showing.splice(id, 1);
    redostack.splice(id, 1);
    undostack.splice(id, 1);
    getEl("layer"+id).remove();
    for (let i = id + 1; i < layercount; i++){
        let layerer = getEl("layer"+i);
        let layererC = getEl("layerC"+i);
        let nid = i - 1;
        layerer.id = layerer.id.slice(0, 5) + nid;
        layererC.id = layererC.id.slice(0, 6) + nid;
        let buttons = getLayerButtons(i);
        buttons.forEach((button) => button.id = button.id.slice(0, 7) + nid);
        setFunctions(buttons, nid);
    }
    if(layer>id)
        layer--;
    layercount--;
}

function swapLayers(id1, id2){
    if (id1 === layer)
        layer = id2;
    else if (id2 === layer)
        layer = id1;

    let a1 = acts[id1];
    let s1 = showing[id1];
    let r1 = redostack[id1];
    let u1 = undostack[id1];

    acts[id1] = acts[id2];
    showing[id1] = showing[id2];
    redostack[id1] = redostack[id2];
    undostack[id1] = undostack[id2];

    acts[id2] = a1;
    showing[id2] = s1;
    redostack[id2] = r1;
    undostack[id2] = u1;

    setFunctions(getLayerButtons(id1), id1);
    setFunctions(getLayerButtons(id2), id2);
}

function moveLayerLeft(id){
    if (id <= 0)
        return;
    refreshLayers = true;
    swapLayers(id, id-1);
}

function moveLayerRight(id){
    if (id >= layercount - 1)
        return;
    refreshLayers = true;
    swapLayers(id, id+1);
}

function drawZoom(z){
    mainCanvas.width = width * z;
    mainCanvas.height = height * z;
    mainCtx.clearRect(0, 0, mainCanvas.width, mainCanvas.height);
    if (gridOn)
        drawGrid(zoom);
    for (let i = 0; i < layercount; i++){
        if (showing[i])
            acts[i].forEach((x) => x.forEach((y) => doAct(y, z)));
    }
}

function drawGrid(z){
    for (let x = 0; x < width; x++)
        for (let y = 0; y < height; y++)
            if ((Math.floor(x / Number(Igridzoom.value)) + Math.floor(y / Number(Igridzoom.value))) % 2 === 0)
                doAct([x, y, "#FFFFFF20"], z);
            else
                doAct([x, y, "#00000020"], z);
}

function setLayer(i)
{
    Ilayer.value = i + 1;
    layer = i;
}

function update(){
    global += 1;
    Izoom.innerHTML = (zoom * 100).toString();
    if (draw)
        Idrawing.innerHTML = "Drawing";
    else
        Idrawing.innerHTML = "Erasing";
    Icolor.style.setProperty("border-color", Icolor.value);
    Iacolor.style.setProperty("border-color", Iacolor.value);
    if (!isNaN(Iwidth.value))
        width = Iwidth.value;
    if (!isNaN(Iheight.value))
        height = Iheight.value;
    if (!isNaN(Ilayer.value) && Ilayer.value >= 1 && Ilayer.value <= layercount)
        if (layer !== Ilayer.value - 1)
        {
            layer = Ilayer.value - 1;
            refreshLayers = true;
        }
        else
            Ilayer.value = layer + 1;
    Ilayermax.innerHTML = layercount;
    drawZoom(zoom);
    drawHolo(zoom);
    updateLayerBar();
}

function getCanvPos(e){
    let rect = mainCanvas.getBoundingClientRect();
    let x = e.clientX - rect.left;
    let y = e.clientY - rect.top;
    x = Math.floor(x / zoom);
    y = Math.floor(y / zoom);
    return [x, y];
}

function drawHolo(z){
    if (draw)
        mainCtx.fillStyle = Icolor.value;
    else
    {
        if (global % 16 < 8)
            mainCtx.fillStyle = "#00000000";
        else
            mainCtx.fillStyle = "#FFF";
    }
    mainCtx.fillRect(mPos[0] * z, mPos[1] * z, z, z);
}

function mouseMoved(e){
    let oPos = mPos;

    mPos = getCanvPos(e);
    if (mousedown && (mPos[0] !== oPos[0] || mPos[1] !== oPos[1]))
        drawPx();
}

function canvasDown(){
    mousedown = true;
    drawPx();
}

function canvasUp(){
    mousedown = false;
}

function drawPx(){
    let x = mPos[0];
    let y = mPos[1];
    let color = Icolor.value;
    addAct(draw, x, y, color);
}

function changeCanvasColor() {
    backgroundLight = !backgroundLight;
    canvasHolder.className = backgroundLight ? "light" : "dark";
}

changeCanvasColor();

function keyDown(e){
    let key = e.key.toLowerCase();
    switch (key){
        case "x":
            let temp = Iacolor.value;
            Iacolor.value = Icolor.value;
            Icolor.value = temp;
            break;
        case "c":
            swapDraw();
            break;
        case "z":
            let thisAct = undostack[layer].pop();
            redostack[layer].push(thisAct);
            setPx(layer, thisAct[0], thisAct[1], thisAct[2]);
            break;
        case "r":
            if (redostack[layer].length === 0)
                break;
            let deAct = redostack[layer].pop();
            undostack[layer].push(deAct);
            setPx(layer, deAct[0], deAct[1], deAct[3]);
            break;
        case "g":
            gridtoggle();
            break;
        case "-":
        case "_":
            zoomout();
            break;
        case "=":
        case "+":
            zoomin();
            break;
        case "b":
            changeCanvasColor();
            break;
    }
}

mainCanvas.onmousedown = canvasDown;

mainCanvas.onmouseup = canvasUp;

document.onmousemove = mouseMoved;

document.onkeydown = keyDown;

setInterval(update, 1/60);