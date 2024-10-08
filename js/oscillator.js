document.querySelectorAll("[textoscillator]").forEach((elem) => {
    let val = elem.innerHTML;
    elem.innerHTML = "";
    for (let i = 0; i < val.length; i++) {
        let spanElem = document.createElement("span");
        spanElem.innerHTML = val[i];
        let off = document.currentScript.getAttribute("oscillatorOffset");
        if (!off)
            off = 0.15;
        spanElem.style.setProperty("animation-delay", (off * i).toString() + "s");
        spanElem.className = "textoscillator";
        elem.appendChild(spanElem);
    }
})