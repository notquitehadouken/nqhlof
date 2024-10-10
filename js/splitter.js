document.querySelectorAll("[textsplitter]").forEach((elem) => {
    let val = elem.innerHTML;
    elem.innerHTML = "";
    for (let i = 0; i < val.length; i++) {
        let spanElem = document.createElement("pre");
        spanElem.innerHTML = val[i];
        let off = document.currentScript.getAttribute("offset");
        if (!off)
            off = 0.15;
        spanElem.style.setProperty("animation-delay", (off * i).toString() + "s");
        spanElem.className = "textsplitter";
        elem.appendChild(spanElem);
    }
})