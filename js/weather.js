let img = document.getElementById("theImage");
setInterval(function(){
    Array.from(document.getElementById("imageSelector").children).forEach((x) => x.className = "hide");
    let oldEl = document.getElementById("start");
    let currEl = oldEl
    let currName = "";
    do {
        oldEl = currEl;
        document.getElementById(currName+"L").className = currEl.className = "";
        if (currEl.value.length === 0)
            return (img.src = "");
        currName = currEl.value + "_" + currName;
    } while ((currEl = document.getElementById(currName)));
    if (img.src !== oldEl.value)
        img.src = oldEl.value;
},30);