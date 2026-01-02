let img = document.getElementById("theImage");
let clean = (showEl)=>{Array.from(document.getElementById("imageSelector").children).forEach((x) => {if(!showEl.includes(x))x.className = "hide"});}

let updateVisuals = function(){
    let showEl = [];
    let oldEl = document.getElementById("start");
    let currEl = oldEl
    let currName = "";
    do {
        oldEl = currEl;
        let label = document.getElementById(currName+"L");
        label.className = currEl.className = "";
        showEl.push(currEl);
        showEl.push(label);
        if (currEl.value.length === 0) {
            clean(showEl);
            return (img.src = "");
        }
        currName = currEl.value + "_" + currName;
    } while ((currEl = document.getElementById(currName)));
    if (img.src !== oldEl.value)
        img.src = oldEl.value;
    clean(showEl);
}
updateVisuals();
document.getElementById("imageSelector").children.forEach((x) => {x.setAttribute("onchange", updateVisuals)});
